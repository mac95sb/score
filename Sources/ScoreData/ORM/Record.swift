import Foundation

/// A type that maps to a database table row.
///
/// Conforming types gain ORM support: query building, insert, update, delete.
///
/// ```swift
/// struct Post: Record {
///     var id: UUID = UUID()
///     var title: String
///     var slug: String
///     var published: Bool = false
///     var createdAt: Date = .now
///     var updatedAt: Date = .now
/// }
/// ```
public protocol Record: Codable, Sendable, Identifiable where ID == UUID {
    var id: UUID { get set }
    var createdAt: Date { get set }
    var updatedAt: Date { get set }
}

extension Record {
    /// The database table name, derived from the type name in snake_case + "s".
    public static var tableName: String {
        let name = String(describing: Self.self)
        var result = ""
        for (i, char) in name.enumerated() {
            if char.isUppercase && i > 0 { result += "_" }
            result += char.lowercased()
        }
        return result + "s"
    }

    /// The table name wrapped in SQLite identifier quotes for safe interpolation
    /// into SQL. Embedded double-quotes are doubled per the SQLite grammar so a
    /// pathological type name can never break out of the identifier.
    public static var quotedTableName: String {
        "\"" + tableName.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }

    /// A quoted index identifier (`"idx_<table>_<suffix>"`) safe for DDL.
    public static func quotedIndexName(_ suffix: String) -> String {
        let raw = "idx_\(tableName)_\(suffix)"
        return "\"" + raw.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}

/// Escape a JSON document key for safe interpolation into a single-quoted
/// SQLite `json_extract` path such as `'$."<key>"'`.
///
/// Two layers are escaped: the SQL string literal (single quotes are doubled)
/// and the JSON path (the key is wrapped in double quotes so characters like
/// `.`, `[`, or `]` in a property name are treated as a literal key rather than
/// path syntax). This is defence-in-depth — keys today come from compile-time
/// key paths — but keeps the builder safe if that ever changes.
func jsonExtractPath(forKey key: String) -> String {
    let escaped =
        key
        .replacingOccurrences(of: "\"", with: "\\\"")
        .replacingOccurrences(of: "'", with: "''")
    return "'$.\"\(escaped)\"'"
}
