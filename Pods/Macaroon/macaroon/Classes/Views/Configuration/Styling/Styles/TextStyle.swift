// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public typealias TextStyle = BaseStyle<TextStyleAttribute>

extension TextStyle {
    public var font: Font? {
        for attribute in self {
            switch attribute {
            case .font(let font): return font
            default: break
            }
        }

        return nil
    }
}

extension TextStyle {
    public func mutate(
        by viewStyle: ViewStyle
    ) -> Self {
        var derivedTextStyle: TextStyle = []

        viewStyle.forEach {
            switch $0 {
            case .backgroundColor(let backgroundColor):
                derivedTextStyle.append(.backgroundColor(backgroundColor))
            case .tintColor(let tintColor):
                derivedTextStyle.append(.tintColor(tintColor))
            }
        }

        return mutate(by: derivedTextStyle)
    }
}

public enum TextStyleAttribute: BaseStyleAttribute {
    /// <mark>
    /// Base
    case backgroundColor(Color)
    case tintColor(Color)

    /// <mark>
    /// Text
    case font(Font)
    case textAlignment(NSTextAlignment)
    case textOverflow(TextOverflow)
    case textColor(Color)
    case content(Text)
}

extension TextStyleAttribute {
    public var id: String {
        switch self {
        case .backgroundColor: return Self.getBackgroundColorAttributeId()
        case .tintColor: return Self.getTintColorAttributeId()
        case .font: return "text.font"
        case .textAlignment: return "text.textAlignment"
        case .textOverflow: return "text.textOverflow"
        case .textColor: return "text.textColor"
        case .content: return "text.content"
        }
    }
}
