// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

extension Customizable where Self: UITextField {
    public func customizeAppearance(
        _ style: TextInputStyle
    ) {
        style.forEach {
            switch $0 {
            case .backgroundColor(let backgroundColor):
                customizeBaseAppearance(
                    backgroundColor: backgroundColor
                )
            case .tintColor(let tintColor):
                customizeBaseAppearance(
                    tintColor: tintColor
                )
            case .backgroundImage(let backgroundImage):
                customizeBaseAppearance(
                    backgroundImage: backgroundImage
                )
            case .font(let font):
                customizeBaseAppearance(
                    font: font
                )
            case .textAlignment(let textAlignment):
                customizeBaseAppearance(
                    textAlignment: textAlignment
                )
            case .textColor(let textColor):
                customizeBaseAppearance(
                    textColor: textColor
                )
            case .content(let content):
                customizeBaseAppearance(
                    content: content
                )
            case .placeholder(let placeholder, let placeholderColor):
                customizeBaseAppearance(
                    placeholder: placeholder,
                    placeholderColor: placeholderColor
                )
            case .clearButtonMode(let clearButtonMode):
                customizeBaseAppearance(
                    clearButtonMode: clearButtonMode
                )
            case .keyboardType(let keyboardType):
                customizeBaseAppearance(
                    keyboardType: keyboardType
                )
            case .returnKeyType(let returnKeyType):
                customizeBaseAppearance(
                    returnKeyType: returnKeyType
                )
            case .autocapitalizationType(let autocapitalizationType):
                customizeBaseAppearance(
                    autocapitalizationType: autocapitalizationType
                )
            case .autocorrectionType(let autocorrectionType):
                customizeBaseAppearance(
                    autocorrectionType: autocorrectionType
                )
            case .textContentType(let textContentType):
                customizeBaseAppearance(
                    textContentType: textContentType
                )
            }
        }
    }

    public func recustomizeAppearance(
        _ style: TextInputStyle
    ) {
        resetAppearance()
        customizeAppearance(
            style
        )
    }

    public func resetAppearance() {
        resetBaseAppearance()

        customizeBaseAppearance(
            backgroundImage: nil
        )
        customizeBaseAppearance(
            font: nil
        )
        customizeBaseAppearance(
            textAlignment: nil
        )
        customizeBaseAppearance(
            textColor: nil
        )
        customizeBaseAppearance(
            content: nil
        )
        customizeBaseAppearance(
            placeholder: nil,
            placeholderColor: nil
        )
        customizeBaseAppearance(
            clearButtonMode: nil
        )
        customizeBaseAppearance(
            keyboardType: nil
        )
        customizeBaseAppearance(
            returnKeyType: nil
        )
        customizeBaseAppearance(
            autocapitalizationType: nil
        )
        customizeBaseAppearance(
            autocorrectionType: nil
        )
        customizeBaseAppearance(
            textContentType: nil
        )
    }
}

extension Customizable where Self: UITextField {
    public func customizeBaseAppearance(
        backgroundImage: Image?
    ) {
        background = backgroundImage?.image
        disabledBackground = backgroundImage?.disabled
    }

    public func customizeBaseAppearance(
        font: Font?
    ) {
        self.font = font?.font
        self.adjustsFontForContentSizeCategory = font?.adjustsFontForContentSizeCategory ?? true
    }

    public func customizeBaseAppearance(
        textAlignment: NSTextAlignment?
    ) {
        self.textAlignment = textAlignment ?? .left
    }

    public func customizeBaseAppearance(
        textColor: Color?
    ) {
        self.textColor = textColor?.color ?? .black
    }

    public func customizeBaseAppearance(
        content: Text?
    ) {
        self.editText = content?.text
    }

    public func customizeBaseAppearance(
        placeholder: Text?,
        placeholderColor: Color?
    ) {
        guard let placeholder = placeholder else {
            self.placeholder = nil
            self.attributedPlaceholder = nil

            return
        }

        switch placeholder.text {
        case .string(let string, _):
            if let placeholderColor = placeholderColor {
                self.attributedPlaceholder =
                    string?.attributed(
                        .textColor(placeholderColor.color)
                    )
            } else {
                self.placeholder = string
            }
        case .attributedString(let attributedString):
            if let placeholderColor = placeholderColor {
                let mAttributedString =
                    NSMutableAttributedString(attributedString: attributedString)
                mAttributedString.addAttribute(
                    .foregroundColor,
                    value: placeholderColor.color,
                    range: NSRange(location: 0, length: attributedString.length)
                )

                self.attributedPlaceholder = mAttributedString
            } else {
                self.attributedPlaceholder = attributedString
            }
        }
    }

    public func customizeBaseAppearance(
        clearButtonMode: UITextField.ViewMode?
    ) {
        self.clearButtonMode = clearButtonMode ?? .never
    }

    public func customizeBaseAppearance(
        keyboardType: UIKeyboardType?
    ) {
        self.keyboardType = keyboardType ?? .default
    }

    public func customizeBaseAppearance(
        returnKeyType: UIReturnKeyType?
    ) {
        self.returnKeyType = returnKeyType ?? .default
    }

    public func customizeBaseAppearance(
        autocapitalizationType: UITextAutocapitalizationType?
    ) {
        self.autocapitalizationType = autocapitalizationType ?? .sentences
    }

    public func customizeBaseAppearance(
        autocorrectionType: UITextAutocorrectionType?
    ) {
        self.autocorrectionType = autocorrectionType ?? .default
    }

    public func customizeBaseAppearance(
        textContentType: UITextContentType?
    ) {
        self.textContentType = textContentType
    }
}

extension Customizable where Self: UITextView {
    public func customizeAppearance(
        _ style: TextInputStyle
    ) {
        style.forEach {
            switch $0 {
            case .backgroundColor(let backgroundColor):
                customizeBaseAppearance(
                    backgroundColor: backgroundColor
                )
            case .tintColor(let tintColor):
                customizeBaseAppearance(
                    tintColor: tintColor
                )
            case .backgroundImage:
                break
            case .font(let font):
                customizeBaseAppearance(
                    font: font
                )
            case .textAlignment(let textAlignment):
                customizeBaseAppearance(
                    textAlignment: textAlignment
                )
            case .textColor(let textColor):
                customizeBaseAppearance(
                    textColor: textColor
                )
            case .content(let content):
                customizeBaseAppearance(
                    content: content
                )
            case .placeholder:
                break
            case .clearButtonMode:
                break
            case .keyboardType(let keyboardType):
                customizeBaseAppearance(
                    keyboardType: keyboardType
                )
            case .returnKeyType(let returnKeyType):
                customizeBaseAppearance(
                    returnKeyType: returnKeyType
                )
            case .autocapitalizationType(let autocapitalizationType):
                customizeBaseAppearance(
                    autocapitalizationType: autocapitalizationType
                )
            case .autocorrectionType(let autocorrectionType):
                customizeBaseAppearance(
                    autocorrectionType: autocorrectionType
                )
            case .textContentType(let textContentType):
                customizeBaseAppearance(
                    textContentType: textContentType
                )
            }
        }
    }

    public func recustomizeAppearance(
        _ style: TextInputStyle
    ) {
        resetAppearance()
        customizeAppearance(
            style
        )
    }

    public func resetAppearance() {
        resetBaseAppearance()

        customizeBaseAppearance(
            font: nil
        )
        customizeBaseAppearance(
            textAlignment: nil
        )
        customizeBaseAppearance(
            textColor: nil
        )
        customizeBaseAppearance(
            content: nil
        )
        customizeBaseAppearance(
            keyboardType: nil
        )
        customizeBaseAppearance(
            returnKeyType: nil
        )
        customizeBaseAppearance(
            autocapitalizationType: nil
        )
        customizeBaseAppearance(
            autocorrectionType: nil
        )
        customizeBaseAppearance(
            textContentType: nil
        )
    }
}

extension Customizable where Self: UITextView {
    public func customizeBaseAppearance(
        font: Font?
    ) {
        self.font = font?.font
        self.adjustsFontForContentSizeCategory = font?.adjustsFontForContentSizeCategory ?? true
    }

    public func customizeBaseAppearance(
        textAlignment: NSTextAlignment?
    ) {
        self.textAlignment = textAlignment ?? .left
    }

    public func customizeBaseAppearance(
        textColor: Color?
    ) {
        self.textColor = textColor?.color ?? .black
    }

    public func customizeBaseAppearance(
        content: Text?
    ) {
        self.editText = content?.text
    }

    public func customizeBaseAppearance(
        keyboardType: UIKeyboardType?
    ) {
        self.keyboardType = keyboardType ?? .default
    }

    public func customizeBaseAppearance(
        returnKeyType: UIReturnKeyType?
    ) {
        self.returnKeyType = returnKeyType ?? .default
    }

    public func customizeBaseAppearance(
        autocapitalizationType: UITextAutocapitalizationType?
    ) {
        self.autocapitalizationType = autocapitalizationType ?? .sentences
    }

    public func customizeBaseAppearance(
        autocorrectionType: UITextAutocorrectionType?
    ) {
        self.autocorrectionType = autocorrectionType ?? .default
    }

    public func customizeBaseAppearance(
        textContentType: UITextContentType?
    ) {
        self.textContentType = textContentType
    }
}
