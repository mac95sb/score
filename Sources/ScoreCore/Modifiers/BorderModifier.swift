// MARK: - BorderModifier

/// A modifier that applies CSS border properties to an element.
///
/// Use ``View/border(color:width:edge:style:on:)`` and its overloads rather
/// than constructing `BorderModifier` directly.
///
/// ```swift
/// Card { ... }
///     .border(color: .muted.opacity(0.2))
///     .border(color: .primary, width: 2, edge: .bottom)
///     .border(radius: .lg)
/// ```
///
/// - SeeAlso: ``View/border(color:width:edge:style:on:)``, ``BorderRadiusModifier``
public struct BorderModifier: ThemeAwareModifier {
    let color: Color?
    let width: Double
    let edge: Edge?
    let edges: [Edge]?
    let style: BorderStyle
    let outline: Color?
    let outlineWidth: Double?
    let outlineOffset: Double?
    let condition: ModifierCondition?

    public init(
        color: Color? = nil,
        width: Double = 1,
        edge: Edge? = nil,
        edges: [Edge]? = nil,
        style: BorderStyle = .solid,
        outline: Color? = nil,
        outlineWidth: Double? = nil,
        outlineOffset: Double? = nil,
        condition: ModifierCondition? = nil
    ) {
        self.color = color; self.width = width; self.edge = edge
        self.edges = edges; self.style = style; self.outline = outline
        self.outlineWidth = outlineWidth; self.outlineOffset = outlineOffset
        self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        var result: [ConditionedDeclaration] = []

        let colorStr = color?.cssValue ?? "currentColor"
        let borderValue = "\(width.cssStr)px \(style.rawValue) \(colorStr)"

        let effectiveEdges: [Edge]
        if let e = edge {
            effectiveEdges = [e]
        } else if let es = edges {
            effectiveEdges = es
        } else {
            effectiveEdges = []
        }

        if effectiveEdges.isEmpty {
            result.append(ConditionedDeclaration("border", borderValue, condition: condition))
        } else {
            for e in effectiveEdges {
                switch e {
                case .top:
                    result.append(ConditionedDeclaration("border-top", borderValue, condition: condition))
                case .right:
                    result.append(ConditionedDeclaration("border-right", borderValue, condition: condition))
                case .bottom:
                    result.append(ConditionedDeclaration("border-bottom", borderValue, condition: condition))
                case .left:
                    result.append(ConditionedDeclaration("border-left", borderValue, condition: condition))
                case .x:
                    result.append(ConditionedDeclaration("border-left",  borderValue, condition: condition))
                    result.append(ConditionedDeclaration("border-right", borderValue, condition: condition))
                case .y:
                    result.append(ConditionedDeclaration("border-top",    borderValue, condition: condition))
                    result.append(ConditionedDeclaration("border-bottom", borderValue, condition: condition))
                }
            }
        }

        if let oc = outline {
            let ow = outlineWidth ?? 1
            result.append(ConditionedDeclaration("outline", "\(ow.cssStr)px solid \(oc.cssValue)", condition: condition))
        }
        if let oo = outlineOffset {
            result.append(ConditionedDeclaration("outline-offset", "\(oo.cssStr)px", condition: condition))
        }
        return result
    }
}

// MARK: - BorderRadiusModifier

public struct BorderRadiusModifier: ThemeAwareModifier {
    let radius: RadiusToken?
    let radiusPx: Double?
    let radiusTopLeft: RadiusToken?
    let radiusTopRight: RadiusToken?
    let radiusBottomLeft: RadiusToken?
    let radiusBottomRight: RadiusToken?
    let condition: ModifierCondition?

    public init(
        radius: RadiusToken? = nil,
        radiusPx: Double? = nil,
        radiusTopLeft: RadiusToken? = nil,
        radiusTopRight: RadiusToken? = nil,
        radiusBottomLeft: RadiusToken? = nil,
        radiusBottomRight: RadiusToken? = nil,
        condition: ModifierCondition? = nil
    ) {
        self.radius = radius; self.radiusPx = radiusPx
        self.radiusTopLeft = radiusTopLeft; self.radiusTopRight = radiusTopRight
        self.radiusBottomLeft = radiusBottomLeft; self.radiusBottomRight = radiusBottomRight
        self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        var result: [ConditionedDeclaration] = []

        if let r = radius {
            let px = theme.radii[r]
            result.append(ConditionedDeclaration("border-radius", "\(px.cssStr)px", condition: condition))
        } else if let px = radiusPx {
            result.append(ConditionedDeclaration("border-radius", "\(px.cssStr)px", condition: condition))
        }

        if let tl = radiusTopLeft {
            result.append(ConditionedDeclaration("border-top-left-radius", "\(theme.radii[tl].cssStr)px", condition: condition))
        }
        if let tr = radiusTopRight {
            result.append(ConditionedDeclaration("border-top-right-radius", "\(theme.radii[tr].cssStr)px", condition: condition))
        }
        if let bl = radiusBottomLeft {
            result.append(ConditionedDeclaration("border-bottom-left-radius", "\(theme.radii[bl].cssStr)px", condition: condition))
        }
        if let br = radiusBottomRight {
            result.append(ConditionedDeclaration("border-bottom-right-radius", "\(theme.radii[br].cssStr)px", condition: condition))
        }

        return result
    }
}
