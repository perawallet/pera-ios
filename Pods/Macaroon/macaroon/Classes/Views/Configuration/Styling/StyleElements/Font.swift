// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol Font {
    var font: UIFont { get }
    var highlighted: UIFont? { get }
    var selected: UIFont? { get }
    var disabled: UIFont? { get }

    var adjustsFontForContentSizeCategory: Bool { get }
}

extension Font {
    public var highlighted: UIFont? {
        return nil
    }
    public var selected: UIFont? {
        return nil
    }
    public var disabled: UIFont? {
        return nil
    }

    public var adjustsFontForContentSizeCategory: Bool {
        return true
    }
}

extension UIFont: Font {
    public var font: UIFont {
        return self
    }
}

public struct CustomFont: Font {
    public var font: UIFont {
        return preferred
    }

    public let preferred: UIFont
    public let adjustsFontForContentSizeCategory: Bool

    public init(
        name: String,
        size: Size,
        textStyle: UIFont.TextStyle? = nil,
        adjustsFontForContentSizeCategory: Bool? = nil
    ) {
        let font =
            UIFont(name: name, size: size.preferred) ??
            UIFont.systemFont(ofSize: size.preferred)

        if let textStyle = textStyle {
            let metrics = UIFontMetrics(forTextStyle: textStyle)

            switch size {
            case .constant:
                self.preferred =
                    metrics.scaledFont(
                        for: font
                    )
            case .scaled(_, let maxSize):
                self.preferred =
                    metrics.scaledFont(
                        for: font,
                        maximumPointSize: maxSize
                    )
            }
        } else {
            self.preferred = font
        }

        self.adjustsFontForContentSizeCategory =
            adjustsFontForContentSizeCategory ?? (textStyle != nil)
    }
}

extension CustomFont {
    public enum Size: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
        case constant(CGFloat)
        case scaled(actual: CGFloat, max: CGFloat)

        public var preferred: CGFloat {
            switch self {
            case .constant(let preferredSize): return preferredSize
            case .scaled(let actualSize, _): return actualSize
            }
        }

        public init(floatLiteral value: FloatLiteralType) {
            self = .constant(CGFloat(value))
        }

        public init(integerLiteral value: Int) {
            self = .constant(CGFloat(value))
        }
    }
}

public struct FontSet: Font {
    public let font: UIFont
    public let highlighted: UIFont?
    public let selected: UIFont?
    public let disabled: UIFont?
    public let adjustsFontForContentSizeCategory: Bool

    public init(
        _ font: UIFont,
        highlighted: UIFont? = nil,
        selected: UIFont? = nil,
        disabled: UIFont? = nil
    ) {
        self.font = font
        self.highlighted = highlighted
        self.selected = selected
        self.disabled = disabled
        self.adjustsFontForContentSizeCategory = true
    }

    public init(
        _ font: CustomFont,
        highlighted: CustomFont? = nil,
        selected: CustomFont? = nil,
        disabled: CustomFont? = nil
    ) {
        self.font = font.preferred
        self.highlighted = highlighted?.preferred
        self.selected = selected?.preferred
        self.disabled = disabled?.preferred
        self.adjustsFontForContentSizeCategory = font.adjustsFontForContentSizeCategory
    }
}

extension UIFont {
    public static func logAll() {
        UIFont.familyNames.forEach { family in
            UIFont.fontNames(
                forFamilyName: family
            ).forEach {
                print($0)
            }
        }
    }
}
