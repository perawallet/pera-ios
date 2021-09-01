// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

open class Label:
    UILabel,
    BorderDrawable,
    CornerDrawable,
    ShadowDrawable {
    public var contentEdgeInsets: LayoutPaddings = (0, 0, 0, 0) {
        didSet { invalidateIntrinsicContentSize() }
    }

    public var shadow: Shadow?

    public private(set) lazy var shadowLayer = CAShapeLayer()

    open override func textRect(
        forBounds bounds: CGRect,
        limitedToNumberOfLines numberOfLines: Int
    ) -> CGRect {
        let textRect =
            super.textRect(
                forBounds: bounds.inset(
                    by: UIEdgeInsets(contentEdgeInsets)
                ),
                limitedToNumberOfLines: numberOfLines
            )

        if text.isNilOrEmpty {
            return textRect
        }

        return textRect.inset(
            by: UIEdgeInsets(contentEdgeInsets).inverted()
        )
    }

    open override func drawText(in rect: CGRect) {
        let someRect =
            text.isNilOrEmpty
                ? rect
                : rect.inset(
                    by: UIEdgeInsets(contentEdgeInsets)
                )
        super.drawText(
            in: someRect
        )
    }
    
    open func preferredUserInterfaceStyleDidChange() {
        drawAppearance(
            shadow: shadow
        )
    }
    
    open func preferredContentSizeCategoryDidChange() { }
    
    open override func layoutSubviews() {
        super.layoutSubviews()

        if bounds.isEmpty {
            return
        }

        preferredMaxLayoutWidth = bounds.width

        guard let shadow = shadow else {
            return
        }

        updateOnLayoutSubviews(
            shadow: shadow
        )
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(
            previousTraitCollection
        )

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
