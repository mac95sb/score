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
}
