// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

extension UILabel {
    public var editText: EditText? {
        get {
            if let attributedText = attributedText {
                return .attributedString(attributedText)
            }
            if let text = text {
                return .string(text, font)
            }
            return nil
        }
        set {
            guard let newEditText = newValue else {
                attributedText = nil
                text = nil
                return
            }
            switch newEditText {
            case .string(let someText, _):
                attributedText = nil
                text = someText
            case .attributedString(let someAttributedText):
                text = nil
                attributedText = someAttributedText
            }
        }
    }
}

extension UITextField {
    public var editText: EditText? {
        get {
            if let attributedText = attributedText {
                return .attributedString(attributedText)
            }
            if let text = text {
                return .string(text, font)
            }
            return nil
        }
        set {
            guard let newEditText = newValue else {
                attributedText = nil
                text = nil
                return
            }
            switch newEditText {
            case .string(let someText, _):
                attributedText = nil
                text = someText
            case .attributedString(let someAttributedText):
                text = nil
                attributedText = someAttributedText
            }
        }
    }
}

extension UITextView {
    public var editText: EditText? {
        get {
            if let attributedText = attributedText {
                return .attributedString(attributedText)
            }
            if let text = text {
                return .string(text, font)
            }
            return nil
        }
        set {
            guard let newEditText = newValue else {
                attributedText = nil
                text = nil
                return
            }
            switch newEditText {
            case .string(let someText, _):
                attributedText = nil
                text = someText
            case .attributedString(let someAttributedText):
                text = nil
                attributedText = someAttributedText
            }
        }
    }
}

extension UIButton {
    public var editTitle: EditText? {
        get {
            if let attributedText = currentAttributedTitle {
                return .attributedString(attributedText)
            }
            if let text = currentTitle {
                return .string(text, titleLabel?.font)
            }
            return nil
        }
        set {
            guard let newEditText = newValue else {
                setAttributedTitle(nil, for: state)
                setTitle(nil, for: state)
                return
            }
            switch newEditText {
            case .string(let title, _):
                setAttributedTitle(nil, for: state)
                setTitle(title, for: state)
            case .attributedString(let attributedTitle):
                setTitle(nil, for: state)
                setAttributedTitle(attributedTitle, for: state)
            }
        }
    }

    public func setEditTitle(_ editTitle: EditText?, for state: UIControl.State) {
        if let editTitle = editTitle {
            switch editTitle {
            case .string(let title, _):
                setTitle(title, for: state)
            case .attributedString(let attributedTitle):
                setAttributedTitle(attributedTitle, for: state)
            }
        } else {
            setAttributedTitle(nil, for: state)
            setTitle(nil, for: state)
        }
    }
}
