import Foundation

/// Converts Swift PascalCase type names to kebab-case CSS class names and
/// generates scoped child-element class names within a component.
///
/// `ArticleCard` → `"article-card"`
/// `BlogPostPage` → `"blog-post-page"`
public enum StyleScope {

    // MARK: - PascalCase → kebab-case

    /// Convert a PascalCase Swift type name to a kebab-case CSS class name.
    ///
    /// ```swift
    /// StyleScope.cssClass(from: "ArticleCard")   // "article-card"
    /// StyleScope.cssClass(from: "BlogPostPage")  // "blog-post-page"
    /// StyleScope.cssClass(from: "")              // ""
    /// ```
    public static func cssClass(from typeName: String) -> String {
        guard !typeName.isEmpty else { return "" }
        let chars = Array(typeName)
        var result = ""
        for i in chars.indices {
            let ch = chars[i]
            if ch.isUppercase && i > 0 {
                let prev = chars[i - 1]
                let next = i + 1 < chars.count ? chars[i + 1] : nil
                // Insert hyphen at lowercase→uppercase transitions (ArticleCard → article-card)
                // and at acronym→word transitions where an uppercase letter precedes an
                // uppercase+lowercase pair (APIPrefix → api-prefix, HTMLParser → html-parser).
                if prev.isLowercase || (prev.isUppercase && next?.isLowercase == true) {
                    result += "-"
                }
            }
            result += ch.lowercased()
        }
        return result
    }

    // MARK: - Child element class names

    /// Generate a child-element CSS class within a component scope.
    ///
    /// The first occurrence of a unique tag within a component requires no extra
    /// class — the tag selector alone is unambiguous.  Second and subsequent
    /// occurrences receive a disambiguating suffixed class.
    ///
    /// When an explicit `roleName` is provided it is used as the suffix instead of
    /// the auto-generated `"<tag>-<occurrence>"` form.
    ///
    /// - Parameters:
    ///   - componentClass: The kebab-case class name of the enclosing component.
    ///   - tag: The HTML tag name (e.g., `"p"`, `"span"`).
    ///   - occurrence: 1-based occurrence index of this tag in the component.
    ///   - roleName: Optional explicit suffix for the generated class.
    /// - Returns: A scoped class string, or `nil` for the first occurrence of a tag
    ///   when no `roleName` is supplied.
    public static func childClass(
        componentClass: String,
        tag: String,
        occurrence: Int,
        roleName: String? = nil
    ) -> String? {
        if occurrence == 1 && roleName == nil { return nil }
        let suffix = roleName ?? "\(tag)-\(occurrence)"
        return "\(componentClass)-\(suffix)"
    }

    /// Generate a class for a repeated element (e.g., a `span` produced inside a
    /// `ForEach` loop) where every instance should share the same class.
    public static func repeatedClass(componentClass: String, tag: String) -> String {
        "\(componentClass)-\(tag)"
    }
}
