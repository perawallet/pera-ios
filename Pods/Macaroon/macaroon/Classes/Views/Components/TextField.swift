// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

open class TextField:
    UITextField,
    BorderDrawable,
    CornerDrawable,
    ShadowDrawable {
    public var leftAccessory: TextFieldAccessory? {
        didSet {
            leftView = leftAccessory?.content
            leftViewMode = leftAccessory?.mode ?? .never
        }
    }
    public var rightAccessory: TextFieldAccessory? {
        didSet {
            rightView = rightAccessory?.content
            rightViewMode = rightAccessory?.mode ?? .never
        }
    }

    public var contentEdgeInsets: LayoutPaddings = (0.0, 8.0, 0.0, 8.0)
    public var textEdgeInsets: LayoutPaddings = (0.0, 8.0, 0.0, 8.0)

    public var shadow: Shadow?

    public private(set) lazy var shadowLayer = CAShapeLayer()

    open func preferredUserInterfaceStyleDidChange() {
        drawAppearance(
            shadow: shadow
        )
    }

    open func preferredContentSizeCategoryDidChange() { }

    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds).inset(by: calculateFinalEdgeInsets(isEditing: false))
    }

    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: bounds).inset(by: calculateFinalEdgeInsets(isEditing: true))
    }

    open override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        guard let accessory = leftAccessory else {
            return super.leftViewRect(forBounds: bounds)
        }
        let size = accessory.size ?? accessory.content.bounds.size
        return CGRect(
            x: contentEdgeInsets.leading,
            y: contentEdgeInsets.top + ((bounds.height - size.height) / 2.0).ceil(),
            width: size.width,
            height: size.height
        )
    }

    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        guard let accessory = rightAccessory else {
            return super.leftViewRect(forBounds: bounds)
        }
        let size = accessory.size ?? accessory.content.bounds.size
        return CGRect(
            x: bounds.width - size.width - contentEdgeInsets.trailing,
            y: contentEdgeInsets.top + ((bounds.height - size.height) / 2.0).ceil(),
            width: size.width,
            height: size.height
        )
    }

    open override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.clearButtonRect(forBounds: bounds)
        let contentEdgeInsetsY = contentEdgeInsets.top + contentEdgeInsets.bottom
        let totalSpacingY = bounds.height - rect.height - contentEdgeInsetsY

        rect.origin.y = contentEdgeInsets.top + ((totalSpacingY / 2.0)).ceil()

        return rect
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        guard let shadow = shadow else {
            return
        }

        updateOnLayoutSubviews(
            shadow: shadow
        )
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                preferredUserInterfaceStyleDidChange()
            }
        }
        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            preferredContentSizeCategoryDidChange()
        }
    }
}

extension TextField {
    func calculateFinalEdgeInsets(isEditing: Bool) -> UIEdgeInsets {
        var finalEdgeInsets = UIEdgeInsets(
            top: contentEdgeInsets.top + textEdgeInsets.top,
            left: textEdgeInsets.leading,
            bottom: contentEdgeInsets.bottom + textEdgeInsets.bottom,
            right: textEdgeInsets.trailing
        )

        if leftView == nil {
            finalEdgeInsets.left += contentEdgeInsets.leading
        }
        if rightView == nil {
            if isEditing {
                finalEdgeInsets.right += clearButtonMode == .never ? contentEdgeInsets.trailing : 0.0
            } else {
                finalEdgeInsets.right += contentEdgeInsets.trailing
            }
        }
        return finalEdgeInsets
    }
}

public struct TextFieldAccessory {
    let content: UIView
    let mode: UITextField.ViewMode
    let size: CGSize?

    public init(
        content: UIView,
        mode: UITextField.ViewMode = .always,
        size: CGSize? = nil
    ) {
        self.content = content
        self.mode = mode
        self.size = size
    }
}
