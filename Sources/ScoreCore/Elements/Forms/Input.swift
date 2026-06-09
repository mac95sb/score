/// The type of an `Input` element.
public enum InputType: Sendable {
    case text
    case email
    case password
    case number
    case tel
    case url
    case search
    case textarea
    case select
    case checkbox
    case radio
    case file
    case hidden
    case date
    case time
    case datetimeLocal
    case month
    case week
    case range
    case color
}

extension InputType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .text:     return "text"
        case .email:    return "email"
        case .password: return "password"
        case .number:   return "number"
        case .tel:      return "tel"
        case .url:      return "url"
        case .search:   return "search"
        case .textarea:      return "textarea"
        case .select:        return "select"
        case .checkbox:      return "checkbox"
        case .radio:         return "radio"
        case .file:          return "file"
        case .hidden:        return "hidden"
        case .date:          return "date"
        case .time:          return "time"
        case .datetimeLocal: return "datetime-local"
        case .month:         return "month"
        case .week:          return "week"
        case .range:         return "range"
        case .color:         return "color"
        }
    }
}

/// Accepted file types for a file `Input`.
public enum FileAccept: String, Sendable {
    case images    = "image/*"
    case documents = ".pdf,.doc,.docx"
    case all       = "*"
}

/// A form input element supporting all 16 input types.
///
/// For `select` inputs, pass `Option` elements in the `content` closure.
/// For `textarea`, the `rows` and `value` parameters are respected.
///
/// ```swift
/// Input(type: .email, name: "email", placeholder: "you@example.com", required: true)
/// Input(type: .select, name: "country") {
///     Option(value: "us") { "United States" }
///     Option(value: "gb") { "United Kingdom" }
/// }
/// ```
public struct Input: View, _HTMLRenderable {
    let type: InputType
    let name: String
    let placeholder: String?
    let value: String?
    let rows: Int?
    let min: Double?
    let max: Double?
    let label: String?
    let required: Bool
    let disabled: Bool
    let accept: FileAccept?
    let content: AnyView?

    // Initialiser without content — used for all non-select, non-textarea types.
    public init(
        type: InputType,
        name: String,
        placeholder: String? = nil,
        value: String? = nil,
        rows: Int? = nil,
        min: Double? = nil,
        max: Double? = nil,
        label: String? = nil,
        required: Bool = false,
        disabled: Bool = false,
        accept: FileAccept? = nil
    ) {
        self.type = type
        self.name = name
        self.placeholder = placeholder
        self.value = value
        self.rows = rows
        self.min = min
        self.max = max
        self.label = label
        self.required = required
        self.disabled = disabled
        self.accept = accept
        self.content = nil
    }

    // Initialiser with content — used for select inputs (Option children).
    public init(
        type: InputType,
        name: String,
        placeholder: String? = nil,
        value: String? = nil,
        rows: Int? = nil,
        min: Double? = nil,
        max: Double? = nil,
        label: String? = nil,
        required: Bool = false,
        disabled: Bool = false,
        accept: FileAccept? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.type = type
        self.name = name
        self.placeholder = placeholder
        self.value = value
        self.rows = rows
        self.min = min
        self.max = max
        self.label = label
        self.required = required
        self.disabled = disabled
        self.accept = accept
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        switch type {

        case .textarea:
            var attrs = "name=\"\(attributeEscape(name))\""
            if let rows = rows { attrs += " rows=\"\(rows)\"" }
            if let ph = placeholder { attrs += " placeholder=\"\(attributeEscape(ph))\"" }
            if required  { attrs += " required" }
            if disabled  { attrs += " disabled" }
            return "<textarea \(attrs)>\(htmlEscape(value ?? ""))</textarea>"

        case .select:
            var attrs = "name=\"\(attributeEscape(name))\""
            if required { attrs += " required" }
            if disabled { attrs += " disabled" }
            let inner = content?.renderHTML(context: &context) ?? ""
            return "<select \(attrs)>\(inner)</select>"

        case .checkbox, .radio:
            var attrs = "type=\"\(type.description)\" name=\"\(attributeEscape(name))\""
            if let v = value { attrs += " value=\"\(attributeEscape(v))\"" }
            if required { attrs += " required" }
            if disabled { attrs += " disabled" }
            var html = "<input \(attrs)>"
            if let lbl = label { html += "<label>\(htmlEscape(lbl))</label>" }
            return html

        default:
            var attrs = "type=\"\(type.description)\" name=\"\(attributeEscape(name))\""
            if let ph = placeholder { attrs += " placeholder=\"\(attributeEscape(ph))\"" }
            if let v  = value       { attrs += " value=\"\(attributeEscape(v))\"" }
            if let mn = min         { attrs += " min=\"\(mn)\"" }
            if let mx = max         { attrs += " max=\"\(mx)\"" }
            if let ac = accept      { attrs += " accept=\"\(ac.rawValue)\"" }
            if required { attrs += " required" }
            if disabled { attrs += " disabled" }
            return "<input \(attrs)>"
        }
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content?.collectCSS(context: &context)
    }
}
