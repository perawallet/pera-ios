// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

public protocol Text {
    var text: EditText { get }
    var highlighted: EditText? { get }
    var selected: EditText? { get }
    var disabled: EditText? { get }
}

extension Text {
    public var highlighted: EditText? {
        return nil
    }
    public var selected: EditText? {
        return nil
    }
    public var disabled: EditText? {
        return nil
    }
}

extension String: Text {
    public var text: EditText {
        return .string(self)
    }
}

extension NSAttributedString: Text {
    public var text: EditText {
        return .attributedString(self)
    }
}

extension EditText: Text {
    public var text: EditText {
        return self
    }
}

extension RawRepresentable where RawValue == String {
    public var text: EditText {
        return rawValue.text
    }
}

public struct TextSet: Text {
    public let text: EditText
    public let highlighted: EditText?
    public let selected: EditText?
    public let disabled: EditText?

    public init(
        _ text: Text,
        highlighted: Text? = nil,
        selected: Text? = nil,
        disabled: Text? = nil
    ) {
        self.text = text.text
        self.highlighted = highlighted?.text
        self.selected = selected?.text
        self.disabled = disabled?.text
    }
}

public enum TextOverflow {
    case singleLine(NSLineBreakMode = .byTruncatingTail) /// <note> Single line.
    case singleLineFitting /// <note> Single line by adjusting font size to fit.
    case multiline(Int, NSLineBreakMode = .byTruncatingTail) /// <note> Certain number of lines.
    case fitting /// <note> Bounding text.
}
