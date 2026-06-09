import Foundation
import Collections

// MARK: - CSS Data Model

/// A single CSS property–value declaration.
///
/// ```swift
/// CSSDeclaration("padding", "1rem")
/// CSSDeclaration("color", "var(--color-muted)")
/// ```
public struct CSSDeclaration: Sendable, Hashable {
    public let property: String
    public let value: String

    public init(_ property: String, _ value: String) {
        self.property = property
        self.value = value
    }

    /// Compact CSS string — no space around the colon.
    var cssString: String { "\(property):\(value)" }
}

// MARK: - CSSCondition

/// A condition that gates when a set of CSS declarations applies.
public enum CSSCondition: Sendable, Hashable {
    /// A CSS pseudo-class selector, e.g. `":hover"`, `":focus-visible"`.
    case pseudoClass(String)
    /// A media query condition, e.g. `"(prefers-color-scheme: dark)"`.
    case mediaQuery(String)
    /// A media query that also has a pseudo-class, e.g. dark-mode hover state.
    case combined(pseudo: String, media: String)

    /// The selector or at-rule string used in a native CSS nesting block.
    var selector: String {
        switch self {
        case .pseudoClass(let p):          return "&\(p)"
        case .mediaQuery(let m):           return "@media \(m)"
        case .combined(_, let m):          return "@media \(m)"
        }
    }
}

// MARK: - CSSRule

/// A CSS rule — selector + declarations + optionally nested rules.
///
/// Uses native CSS nesting so that component styles can be emitted as a single
/// self-contained block.
public struct CSSRule: Sendable {
    public var selector: String
    public var declarations: [CSSDeclaration]
    public var nested: [CSSRule]

    public init(
        selector: String,
        declarations: [CSSDeclaration] = [],
        nested: [CSSRule] = []
    ) {
        self.selector = selector
        self.declarations = declarations
        self.nested = nested
    }

    // MARK: Rendering

    /// Render to a pretty-printed CSS string with native nesting.
    public func render(indent: String = "") -> String {
        var lines: [String] = ["\(indent)\(selector) {"]
        for decl in declarations {
            lines.append("\(indent)  \(decl.cssString);")
        }
        for rule in nested {
            lines.append(rule.render(indent: indent + "  "))
        }
        lines.append("\(indent)}")
        return lines.joined(separator: "\n")
    }

    /// Render minified — no whitespace or newlines.
    public func renderMinified() -> String {
        var out = "\(selector){"
        let declStr = declarations.map(\.cssString).joined(separator: ";")
        out += declStr
        if !declarations.isEmpty && !nested.isEmpty { out += ";" }
        out += nested.map { $0.renderMinified() }.joined()
        out += "}"
        return out
    }
}

// MARK: - ComponentStyleBlock

/// All styles accumulated for a single component class selector.
public struct ComponentStyleBlock: Sendable {
    /// Base declarations for the component root selector (`.component-name { … }`).
    public var declarations: [CSSDeclaration] = []
    /// Nested rules — pseudo-classes, media queries, child element selectors.
    public var nested: [CSSRule] = []

    /// Add a declaration, optionally gated by a condition.
    mutating func add(_ declaration: CSSDeclaration, condition: CSSCondition? = nil) {
        guard let condition = condition else {
            declarations.append(declaration)
            return
        }

        // For a combined condition, nest the pseudo inside the media query.
        switch condition {
        case .combined(let pseudo, let media):
            let mediaSelector = "@media \(media)"
            let pseudoSelector = "&\(pseudo)"
            if let mediaIdx = nested.firstIndex(where: { $0.selector == mediaSelector }) {
                if let pseudoIdx = nested[mediaIdx].nested.firstIndex(where: { $0.selector == pseudoSelector }) {
                    nested[mediaIdx].nested[pseudoIdx].declarations.append(declaration)
                } else {
                    nested[mediaIdx].nested.append(CSSRule(selector: pseudoSelector, declarations: [declaration]))
                }
            } else {
                let pseudoRule = CSSRule(selector: pseudoSelector, declarations: [declaration])
                nested.append(CSSRule(selector: mediaSelector, declarations: [], nested: [pseudoRule]))
            }

        default:
            let selectorStr = condition.selector
            if let idx = nested.firstIndex(where: { $0.selector == selectorStr }) {
                nested[idx].declarations.append(declaration)
            } else {
                nested.append(CSSRule(selector: selectorStr, declarations: [declaration]))
            }
        }
    }

    /// Convert to a `CSSRule` for the given component CSS class.
    public func toRule(componentClass: String) -> CSSRule {
        CSSRule(selector: ".\(componentClass)", declarations: declarations, nested: nested)
    }

    /// Whether this block contains any CSS at all.
    public var isEmpty: Bool { declarations.isEmpty && nested.isEmpty }
}

// MARK: - CSSCollectionContext

/// Mutable context threaded through the CSS collection pass.
///
/// Each component renders a complete sub-tree; the context accumulates a
/// `ComponentStyleBlock` per component class, merging declarations from all
/// modifier chains encountered.
public struct CSSCollectionContext: Sendable {
    /// Rules indexed by component CSS class name, in declaration order.
    public var componentRules: OrderedDictionary<String, ComponentStyleBlock> = [:]

    /// The kebab-case class name of the component currently being collected.
    public var currentComponentClass: String = ""

    /// Active modifier stack — innermost modifier is last.
    public var modifierStack: [any ViewModifier] = []

    public init() {}

    // MARK: - Modifier stack

    mutating func pushModifier(_ modifier: any ViewModifier) {
        modifierStack.append(modifier)
    }

    mutating func popModifier() {
        if !modifierStack.isEmpty { modifierStack.removeLast() }
    }

    // MARK: - Declaration recording

    /// Record a CSS declaration for the current component, applying the active
    /// modifier condition (if any).
    mutating func record(_ declaration: CSSDeclaration, condition: CSSCondition? = nil) {
        let cls = currentComponentClass
        guard !cls.isEmpty else { return }
        componentRules[cls, default: ComponentStyleBlock()].add(declaration, condition: condition)
    }

    /// Record multiple declarations at once.
    mutating func record(_ declarations: [CSSDeclaration], condition: CSSCondition? = nil) {
        for decl in declarations { record(decl, condition: condition) }
    }
}

// MARK: - CSSCollector

/// Collects CSS rules from a `View` tree.
///
/// Traverse a view tree and returns an array of `CSSRule` values that can be
/// rendered to a stylesheet.
public struct CSSCollector {
    public init() {}

    /// Collect all CSS from a view, scoped to the given component type name.
    ///
    /// - Parameters:
    ///   - view: The view tree to collect from.
    ///   - componentTypeName: PascalCase Swift type name; converted to kebab-case
    ///     for the component CSS class.
    /// - Returns: An array of top-level `CSSRule` values — one per component class
    ///   that contributed styles.
    public func collect<V: View>(from view: V, componentTypeName: String) -> [CSSRule] {
        var ctx = CSSCollectionContext()
        ctx.currentComponentClass = StyleScope.cssClass(from: componentTypeName)
        view._collectCSSInto(&ctx)
        return ctx.componentRules.compactMap { (cls, block) in
            guard !block.isEmpty else { return nil }
            return block.toRule(componentClass: cls)
        }
    }

    /// Render collected CSS to a string, with optional minification.
    public func stylesheet<V: View>(
        from view: V,
        componentTypeName: String,
        minified: Bool = false
    ) -> String {
        let rules = collect(from: view, componentTypeName: componentTypeName)
        if minified {
            return rules.map { $0.renderMinified() }.joined()
        } else {
            return rules.map { $0.render() }.joined(separator: "\n\n")
        }
    }
}
