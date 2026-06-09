import Foundation

#if canImport(SQLite3)
import SQLite3
#else
import CSQLite
#endif

// MARK: - SQLValue

/// A value that can be stored in or retrieved from SQLite.
public typealias SQLValue = (any Sendable & Codable)?

// MARK: - SQLite Connection

/// A low-level actor wrapping a SQLite3 database handle.
///
/// All operations are serialised through the actor's executor, providing
/// safe concurrent access from multiple Swift async tasks.
public actor SQLiteConnection {
    private var db: OpaquePointer?
    private let path: String

    public init(path: String) async throws {
        self.path = path
        if sqlite3_open(path, &db) != SQLITE_OK {
            let msg = db.map { String(cString: sqlite3_errmsg($0)) } ?? "Unknown error"
            throw SQLiteError.cannotOpen(path, message: msg)
        }
        // WAL mode for better concurrency; foreign key enforcement
        _ = try? await _execute("PRAGMA journal_mode=WAL")
        _ = try? await _execute("PRAGMA foreign_keys=ON")
    }

    deinit {
        if let db = db { sqlite3_close(db) }
    }

    // MARK: - DDL

    /// Create the table for a `Record` type if it does not already exist.
    ///
    /// The schema uses a JSON `data` column so the exact Codable layout never
    /// needs to be reflected at the SQL level.  Indexed on `id`,
    /// `created_at`, and `updated_at` for common query patterns.
    public func createTable<R: Record>(for type: R.Type) async throws {
        let sql = """
        CREATE TABLE IF NOT EXISTS \(R.tableName) (
            id         TEXT PRIMARY KEY NOT NULL,
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now')),
            data       TEXT NOT NULL
        );
        CREATE INDEX IF NOT EXISTS idx_\(R.tableName)_created_at ON \(R.tableName)(created_at);
        CREATE INDEX IF NOT EXISTS idx_\(R.tableName)_updated_at ON \(R.tableName)(updated_at);
        """
        // sqlite3_exec can run multiple statements
        guard let db = db else { throw SQLiteError.notConnected }
        let rc = sqlite3_exec(db, sql, nil, nil, nil)
        if rc != SQLITE_OK {
            throw SQLiteError.executionFailed(String(cString: sqlite3_errmsg(db)))
        }
    }

    // MARK: - CRUD

    /// Insert or replace a record (upsert by primary key).
    public func insert<R: Record>(_ record: R) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(record)
        guard let json = String(data: data, encoding: .utf8) else {
            throw SQLiteError.encodingFailed("UTF-8 conversion failed for \(R.tableName)")
        }
        let sql = """
        INSERT OR REPLACE INTO \(R.tableName) (id, created_at, updated_at, data)
        VALUES (?, ?, ?, ?)
        """
        let params: [SQLValue] = [
            record.id.uuidString,
            iso8601(record.createdAt),
            iso8601(record.updatedAt),
            json
        ]
        _ = try await _execute(sql, parameters: params)
    }

    /// Update an existing record's `data`, `updated_at` columns by primary key.
    public func update<R: Record>(_ record: R) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(record)
        guard let json = String(data: data, encoding: .utf8) else {
            throw SQLiteError.encodingFailed("UTF-8 conversion failed for \(R.tableName)")
        }
        let sql = """
        UPDATE \(R.tableName)
        SET updated_at = ?, data = ?
        WHERE id = ?
        """
        let params: [SQLValue] = [
            iso8601(record.updatedAt),
            json,
            record.id.uuidString
        ]
        _ = try await _execute(sql, parameters: params)
    }

    /// Delete a record by type and UUID.
    public func delete<R: Record>(_ type: R.Type, id: UUID) async throws {
        _ = try await _execute(
            "DELETE FROM \(R.tableName) WHERE id = ?",
            parameters: [id.uuidString]
        )
    }

    /// Query records of a given type using a raw SQL statement.
    public func query<R: Record>(_ type: R.Type, sql: String, parameters: [SQLValue] = []) async throws -> [R] {
        let rows = try await _execute(sql, parameters: parameters)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try rows.map { row in
            guard let jsonStr = row["data"] as? String,
                  let jsonData = jsonStr.data(using: .utf8) else {
                throw SQLiteError.decodingFailed("Missing or invalid `data` column in \(R.tableName)")
            }
            return try decoder.decode(R.self, from: jsonData)
        }
    }

    // MARK: - Raw execution (internal + public)

    /// Execute a SQL statement and return rows as `[String: SQLValue]`.
    public func execute(_ sql: String, parameters: [SQLValue] = []) async throws -> [[String: SQLValue]] {
        try await _execute(sql, parameters: parameters)
    }

    // MARK: - Transaction primitives

    public func beginTransaction() async throws {
        _ = try await _execute("BEGIN")
    }

    public func commitTransaction() async throws {
        _ = try await _execute("COMMIT")
    }

    public func rollbackTransaction() async throws {
        _ = try await _execute("ROLLBACK")
    }

    // MARK: - Private implementation

    private func _execute(_ sql: String, parameters: [SQLValue] = []) async throws -> [[String: SQLValue]] {
        guard let db = db else { throw SQLiteError.notConnected }

        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw SQLiteError.prepareFailed(String(cString: sqlite3_errmsg(db)))
        }
        defer { if let s = stmt { sqlite3_finalize(s) } }

        // Bind parameters
        for (index, param) in parameters.enumerated() {
            let idx = Int32(index + 1)
            if let p = param {
                bindValue(stmt: stmt!, index: idx, value: p)
            } else {
                sqlite3_bind_null(stmt, idx)
            }
        }

        // Step and collect rows
        var rows: [[String: SQLValue]] = []
        var rc = sqlite3_step(stmt)
        while rc == SQLITE_ROW {
            var row: [String: SQLValue] = [:]
            let colCount = sqlite3_column_count(stmt)
            for col in 0..<colCount {
                let name = String(cString: sqlite3_column_name(stmt, col))
                row[name] = columnValue(stmt: stmt!, col: col)
            }
            rows.append(row)
            rc = sqlite3_step(stmt)
        }

        if rc != SQLITE_DONE && rc != SQLITE_OK {
            throw SQLiteError.executionFailed(String(cString: sqlite3_errmsg(db)))
        }

        return rows
    }

    private func bindValue(stmt: OpaquePointer, index: Int32, value: any Sendable & Codable) {
        if let s = value as? String {
            sqlite3_bind_text(stmt, index, (s as NSString).utf8String, -1, nil)
        } else if let i = value as? Int {
            sqlite3_bind_int64(stmt, index, Int64(i))
        } else if let i = value as? Int64 {
            sqlite3_bind_int64(stmt, index, i)
        } else if let i = value as? Int32 {
            sqlite3_bind_int64(stmt, index, Int64(i))
        } else if let d = value as? Double {
            sqlite3_bind_double(stmt, index, d)
        } else if let f = value as? Float {
            sqlite3_bind_double(stmt, index, Double(f))
        } else if let b = value as? Bool {
            sqlite3_bind_int(stmt, index, b ? 1 : 0)
        } else if let data = value as? Data {
            data.withUnsafeBytes { ptr in
                _ = sqlite3_bind_blob(stmt, index, ptr.baseAddress, Int32(data.count), nil)
            }
        } else {
            // Fall back to string representation
            let s = "\(value)"
            sqlite3_bind_text(stmt, index, (s as NSString).utf8String, -1, nil)
        }
    }

    private func columnValue(stmt: OpaquePointer, col: Int32) -> SQLValue {
        switch sqlite3_column_type(stmt, col) {
        case SQLITE_TEXT:
            return String(cString: sqlite3_column_text(stmt, col))
        case SQLITE_INTEGER:
            return Int(sqlite3_column_int64(stmt, col))
        case SQLITE_FLOAT:
            return sqlite3_column_double(stmt, col)
        case SQLITE_NULL:
            return nil
        case SQLITE_BLOB:
            guard let ptr = sqlite3_column_blob(stmt, col) else { return nil }
            let bytes = Int(sqlite3_column_bytes(stmt, col))
            return Data(bytes: ptr, count: bytes)
        default:
            return String(cString: sqlite3_column_text(stmt, col))
        }
    }

    private func iso8601(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}

// MARK: - SQLiteError

public enum SQLiteError: Error, Sendable {
    case cannotOpen(String, message: String)
    case notConnected
    case prepareFailed(String)
    case executionFailed(String)
    case encodingFailed(String)
    case decodingFailed(String)
}
