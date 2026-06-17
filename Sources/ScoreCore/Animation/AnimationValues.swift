// MARK: - Animation duration

public struct AnimationDuration: Sendable {
    public let ms: Int
    public init(_ ms: Int) { self.ms = ms }
    public var css: String { "\(ms)ms" }
}

extension Int {
    public var ms: AnimationDuration { AnimationDuration(self) }
}

extension Double {
    public var ms: AnimationDuration { AnimationDuration(Int(self)) }
}

// MARK: - Animation timing

public enum AnimationTiming: Sendable {
    case linear
    case ease
    case easeIn
    case easeOut
    case easeInOut
    case custom(String)

    public var css: String {
        switch self {
        case .linear:        return "linear"
        case .ease:          return "ease"
        case .easeIn:        return "ease-in"
        case .easeOut:       return "ease-out"
        case .easeInOut:     return "ease-in-out"
        case .custom(let s): return s
        }
    }
}

// MARK: - Animation iterations

public struct AnimationIterations: Sendable {
    let value: String
    public static let infinite = AnimationIterations(value: "infinite")
    public static func times(_ n: Int) -> AnimationIterations { AnimationIterations(value: "\(n)") }
    public static let once = times(1)
    public var css: String { value }
}

// MARK: - Animation

public enum Animation: Sendable {
    case none
    case spin
    case ping
    case pulse
    case bounce
    case fadeIn
    case fadeOut
    case slideInLeft
    case slideInRight
    case slideInUp
    case slideInDown
    case custom(String)

    public var css: String {
        switch self {
        case .none:           return "none"
        case .spin:           return "spin"
        case .ping:           return "ping"
        case .pulse:          return "pulse"
        case .bounce:         return "bounce"
        case .fadeIn:         return "fade-in"
        case .fadeOut:        return "fade-out"
        case .slideInLeft:    return "slide-in-left"
        case .slideInRight:   return "slide-in-right"
        case .slideInUp:      return "slide-in-up"
        case .slideInDown:    return "slide-in-down"
        case .custom(let s):  return s
        }
    }
}

// MARK: - Transition property

public enum TransitionProperty: Sendable {
    case all
    case transform
    case opacity
    case color
    case backgroundColor
    case border
    case shadow
    case filter
    case custom(String)

    public var css: String {
        switch self {
        case .all:             return "all"
        case .transform:       return "transform"
        case .opacity:         return "opacity"
        case .color:           return "color"
        case .backgroundColor: return "background-color"
        case .border:          return "border"
        case .shadow:          return "box-shadow"
        case .filter:          return "filter"
        case .custom(let s):   return s
        }
    }
}
