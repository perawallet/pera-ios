// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

public enum EditText {
    case string(String?, UIFont? = nil)
    case attributedString(NSAttributedString)
}

extension EditText {
    public var string: String? {
        switch self {
        case .string(let string, _):
            return string
        case .attributedString(let attributedString):
            return attributedString.string
        }
    }
}

extension EditText {
    public var isEmpty: Bool {
        switch self {
        case .string(let text, _):
            return text.nonNil.isEmpty
        case .attributedString(let attributedText):
            return attributedText.string.isEmpty
        }
    }
}

extension EditText {
    public func boundingSize(multiline: Bool = true, fittingSize: CGSize = .greatestFiniteMagnitude) -> CGSize {
        switch self {
        case .string(let text, let font):
            return text?.boundingSize(attributes: .font(font), multiline: multiline, fittingSize: fittingSize) ?? .zero
        case .attributedString(let attributedText):
            return attributedText.boundingSize(multiline: multiline, fittingSize: fittingSize)
        }
    }
}

extension EditText: Equatable {
    public static func == (lhs: EditText, rhs: EditText) -> Bool {
        switch (lhs, rhs) {
        case (.string(let lString, _), .string(let rString, _)):
            return lString == rString
        case (.string(let string, _), .attributedString(let attributedString)),
             (.attributedString(let attributedString), .string(let string, _)):
            return string == attributedString.string
        case (.attributedString(let lAttributedString), .attributedString(let rAttributedString)):
            return lAttributedString.string == rAttributedString.string
        }
    }
}

extension EditText: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension EditText: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .string(nil)
    }
}

extension Optional where Wrapped == EditText {
    public var isNilOrEmpty: Bool {
        guard let someSelf = self else {
            return true
        }

        switch someSelf {
        case .string(let string, _): return string.isNilOrEmpty
        case .attributedString(let attributedString): return attributedString.string.isEmpty
        }
    }

    public var nonNil: EditText {
        return self ?? .string("")
    }
}

extension Optional where Wrapped == EditText {
    public func boundingSize(
        multiline: Bool = true,
        fittingSize: CGSize = .greatestFiniteMagnitude
    ) -> CGSize {
        switch self {
        case .none:
            return .zero
        case .some(let some):
            return some.boundingSize(
                multiline: multiline,
                fittingSize: fittingSize
            )
        }
    }
}
