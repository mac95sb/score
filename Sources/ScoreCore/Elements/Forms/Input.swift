/// The type of an ``Input`` element, mapping to the HTML `type` attribute or special rendering.
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
        case .text: return "text"
        case .email: return "email"
        case .password: return "password"
        case .number: return "number"
        case .tel: return "tel"
        case .url: return "url"
        case .search: return "search"
        case .textarea: return "textarea"
        case .select: return "select"
        case .checkbox: return "checkbox"
        case .radio: return "radio"
        case .file: return "file"
        case .hidden: return "hidden"
        case .date: return "date"
        case .time: return "time"
        case .datetimeLocal: return "datetime-local"
        case .month: return "month"
        case .week: return "week"
        case .range: return "range"
        case .color: return "color"
        }
    }
}

/// Accepted file types for a file ``Input``.
public enum FileAccept: String, Sendable {
    case images = "image/*"
    case documents = ".pdf,.doc,.docx"
    case all = "*"
}

/// A versatile form control supporting text, select, textarea, and all standard HTML input types.
///
/// `Input` is a single element that handles every form control variant. The
/// `type` parameter drives which HTML element or `type` attribute is emitted:
/// - Most types render as `<input type="…">`.
/// - `.textarea` renders as a multi-line `<textarea>` respecting `rows` and `value`.
/// - `.select` renders as `<select>` and expects ``Option`` or ``OptionGroup``
///   children in the `content` closure.
/// - `.checkbox` and `.radio` render an `<input>` followed by an inline
///   `<label>` when `label` is supplied.
///
/// Always associate an input with a visible ``Label`` (via matching `id`/`for`
/// attributes) for accessibility. Use ``Fieldset`` and ``Legend`` to group
/// related controls.
///
/// - Parameters:
///   - type: The kind of input control to render.
///   - name: The `name` attribute sent with the form submission.
///   - placeholder: Hint text shown when the field is empty.
///   - value: Pre-filled value for the control. Pass a `Binding<String>` (via the `$` prefix) to keep an `@State` variable in sync with the field's value.
///   - rows: Number of visible rows for `.textarea`. Ignored by other types.
///   - min: Minimum value for `.number`, `.range`, `.date`, and similar types.
///   - max: Maximum value for `.number`, `.range`, `.date`, and similar types.
///   - label: Inline label text appended after `.checkbox` and `.radio` inputs.
///   - required: Adds the `required` attribute; browsers block submission if empty.
///   - disabled: Greys out the control and prevents user interaction.
///   - accept: Restricts accepted file types for `.file` inputs.
///   - content: Child views (``Option`` / ``OptionGroup``) for `.select` inputs.
///
/// ## Example
///
/// ```swift
/// Form(action: "/register", method: .post) {
///     Input(type: .text,     name: "name",     placeholder: "Full name",         required: true)
///     Input(type: .email,    name: "email",    placeholder: "you@example.com",   required: true)
///     Input(type: .password, name: "password", placeholder: "Min 8 characters",  required: true)
///     Input(type: .textarea, name: "bio",      placeholder: "Tell us about you", rows: 4)
///     Input(type: .select,   name: "role") {
///         Option(value: "dev")     { "Developer" }
///         Option(value: "design")  { "Designer" }
///         Option(value: "pm")      { "Product" }
///     }
///     Input(type: .checkbox, name: "terms", value: "1", label: "I accept the terms")
///     Button(.primary, type: .submit) { "Create account" }
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <input type="email" name="email" placeholder="you@example.com" required>
/// <select name="role"><option value="dev">Developer</option>…</select>
/// ```
///
/// - SeeAlso: ``Label``, ``Fieldset``, ``Form``, ``Option``, ``OptionGroup``
public struct Input: View, _HTMLRenderable {
    let type: InputType
    let id: String?
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
        id: String? = nil,
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
        self.id = id
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

    /// Initialiser that accepts a `Binding<String>` for the value, keeping an
    /// `@State` variable in sync with the field's rendered initial value.
    public init(
        type: InputType,
        id: String? = nil,
        name: String,
        placeholder: String? = nil,
        value: Binding<String>,
        rows: Int? = nil,
        min: Double? = nil,
        max: Double? = nil,
        label: String? = nil,
        required: Bool = false,
        disabled: Bool = false,
        accept: FileAccept? = nil
    ) {
        self.type = type
        self.id = id
        self.name = name
        self.placeholder = placeholder
        self.value = value.wrappedValue
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
        id: String? = nil,
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
        self.id = id
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
            if let id { attrs = "id=\"\(attributeEscape(id))\" " + attrs }
            if let rows = rows { attrs += " rows=\"\(rows)\"" }
            if let ph = placeholder { attrs += " placeholder=\"\(attributeEscape(ph))\"" }
            if required { attrs += " required" }
            if disabled { attrs += " disabled" }
            return "<textarea \(attrs)>\(htmlEscape(value ?? ""))</textarea>"

        case .select:
            var attrs = "name=\"\(attributeEscape(name))\""
            if let id { attrs = "id=\"\(attributeEscape(id))\" " + attrs }
            if required { attrs += " required" }
            if disabled { attrs += " disabled" }
            let inner = content?.renderHTML(context: &context) ?? ""
            return "<select \(attrs)>\(inner)</select>"

        case .checkbox, .radio:
            var attrs = "type=\"\(type.description)\" name=\"\(attributeEscape(name))\""
            if let id { attrs = "id=\"\(attributeEscape(id))\" " + attrs }
            if let v = value { attrs += " value=\"\(attributeEscape(v))\"" }
            if required { attrs += " required" }
            if disabled { attrs += " disabled" }
            var html = "<input \(attrs)>"
            if let lbl = label { html += "<label>\(htmlEscape(lbl))</label>" }
            return html

        default:
            var attrs = "type=\"\(type.description)\" name=\"\(attributeEscape(name))\""
            if let id { attrs = "id=\"\(attributeEscape(id))\" " + attrs }
            if let ph = placeholder { attrs += " placeholder=\"\(attributeEscape(ph))\"" }
            if let v = value { attrs += " value=\"\(attributeEscape(v))\"" }
            if let mn = min { attrs += " min=\"\(mn)\"" }
            if let mx = max { attrs += " max=\"\(mx)\"" }
            if let ac = accept { attrs += " accept=\"\(ac.rawValue)\"" }
            if required { attrs += " required" }
            if disabled { attrs += " disabled" }
            return "<input \(attrs)>"
        }
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content?.collectCSS(context: &context)
    }
}
