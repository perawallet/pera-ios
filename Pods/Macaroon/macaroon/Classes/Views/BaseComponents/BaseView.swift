// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

open class BaseView:
    UIView,
    BorderDrawable,
    CornerDrawable,
    ShadowDrawable {
    public var shadow: Shadow?

    public private(set) lazy var shadowLayer = CAShapeLayer()

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func preferredUserInterfaceStyleDidChange() {
        drawAppearance(
            shadow: shadow
        )
    }

    open func preferredContentSizeCategoryDidChange() { }

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

public typealias View = BaseView & ViewComposable
