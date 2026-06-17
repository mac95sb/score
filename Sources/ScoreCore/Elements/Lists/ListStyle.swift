/// The visual and semantic style of a ``List``, controlling which HTML element and marker type to use.
public enum ListStyle: Sendable, Equatable {
    /// A bulleted list (`<ul>`).
    case unordered
    /// A numbered list (`<ol>`).
    case ordered
    /// A decimal-numbered ordered list (`<ol type="1">`).
    case decimal
    /// An alphabetically-lettered ordered list (`<ol type="a">`).
    case alpha
    /// A list with no visible bullets or numbers.
    case none
}
