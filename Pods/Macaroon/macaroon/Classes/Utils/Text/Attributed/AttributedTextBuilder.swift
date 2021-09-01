// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public class AttributedTextBuilder {
    private var attributes: [Attribute] = []
    private let text: String

    public init(_ text: String = "") {
        self.text = text
    }

    @discardableResult
    public func addAttribute(_ attribute: Attribute) -> AttributedTextBuilder {
        attributes.append(attribute)
        return self
    }

    public func build() -> NSAttributedString {
        return NSAttributedString(string: text, attributes: attributes.asSystemAttributes())
    }
}

extension AttributedTextBuilder {
    public enum Attribute {
        case font(UIFont?)
        case letterSpacing(CGFloat)
        case paragraph(Paragraph)
        case textColor(UIColor?)
        case underline(UIColor?)
    }
}

extension AttributedTextBuilder {
    public struct Paragraph {
        public var alignment: NSTextAlignment?
        public var lineBreakMode: NSLineBreakMode?
        public var lineHeight: CGFloat?
        public var lineHeightMultiple: CGFloat?
        public var lineSpacing: CGFloat?

        init() { }

        func asSystemParagrapStyle() -> NSParagraphStyle {
            let paragraphStyle = NSMutableParagraphStyle()

            if let aligment = alignment {
                paragraphStyle.alignment = aligment
            }
            if let lineBreakMode = lineBreakMode {
                paragraphStyle.lineBreakMode = lineBreakMode
            }
            if let lineHeight = lineHeight {
                paragraphStyle.minimumLineHeight = lineHeight
                paragraphStyle.maximumLineHeight = lineHeight
            }
            if let lineHeightMultiple = lineHeightMultiple {
                paragraphStyle.lineHeightMultiple = lineHeightMultiple
            }
            if let lineSpacing = lineSpacing {
                paragraphStyle.lineSpacing = lineSpacing
            }
            return paragraphStyle
        }
    }
}

extension AttributedTextBuilder.Paragraph {
    public enum Attribute {
        case alignment(NSTextAlignment)
        case lineBreakMode(NSLineBreakMode)
        case lineHeight(CGFloat)
        case lineHeightMultiple(CGFloat)
        case lineSpacing(CGFloat)
    }
}

extension AttributedTextBuilder.Paragraph: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: AttributedTextBuilder.Paragraph.Attribute...) {
        self.init()

        elements.forEach { element in
            switch element {
            case .alignment(let someAlignment):
                alignment = someAlignment
            case .lineBreakMode(let someLineBreakMode):
                lineBreakMode = someLineBreakMode
            case .lineHeight(let someLineHeight):
                lineHeight = someLineHeight
            case .lineHeightMultiple(let someLineHeightMultiple):
                lineHeightMultiple = someLineHeightMultiple
            case .lineSpacing(let someLineSpacing):
                lineSpacing = someLineSpacing
            }
        }
    }
}

extension Array where Element == AttributedTextBuilder.Attribute {
    public func asSystemAttributes() -> [NSAttributedString.Key: Any] {
        return reduce(into: [NSAttributedString.Key: Any]()) { systemAttributes, attribute in
            switch attribute {
            case .font(let .some(font)):
                systemAttributes[.font] = font
            case .letterSpacing(let letterSpacing):
                systemAttributes[.kern] = letterSpacing
            case .paragraph(let paragraph):
                systemAttributes[.paragraphStyle] = paragraph.asSystemParagrapStyle()
            case .textColor(let .some(textColor)):
                systemAttributes[.foregroundColor] = textColor
            case .underline(let .some(underlineColor)):
                systemAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
                systemAttributes[.underlineColor] = underlineColor
            default:
                break
            }
        }
    }
}
