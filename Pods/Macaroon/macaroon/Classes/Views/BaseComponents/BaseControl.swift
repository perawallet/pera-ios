// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

open class BaseControl:
    UIControl,
    BorderDrawable,
    CornerDrawable,
    ShadowDrawable {
    public var shadow: Shadow?

    public private(set) lazy var shadowLayer = CAShapeLayer()

    open override var isEnabled: Bool {
        didSet { recustomizeAppearanceWhenStateDidChange() }
    }
    open override var isSelected: Bool {
        didSet { recustomizeAppearanceWhenStateDidChange() }
    }
    open override var isHighlighted: Bool {
        didSet { recustomizeAppearanceWhenStateDidChange() }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        recustomizeAppearance(for: .normal)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func recustomizeAppearance(for state: UIControl.State) { }
    open func recustomizeAppearance(for touchState: UIControl.TouchState) { }

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

    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        recustomizeAppearance(for: .began)
        return true
    }

    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        recustomizeAppearance(for: .began)
        return true
    }

    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        recustomizeAppearance(for: .ended)
    }

    open override func cancelTracking(with event: UIEvent?) {
        recustomizeAppearance(for: .ended)
    }
}

extension BaseControl {
    public func recustomizeAppearanceWhenStateDidChange() {
        if isEnabled {
            if isSelected {
                recustomizeAppearance(for: .selected)
            } else if isHighlighted {
                recustomizeAppearance(for: .highlighted)
            } else {
                recustomizeAppearance(for: .normal)
            }
        } else {
            recustomizeAppearance(for: .disabled)
        }
    }
}

extension UIControl {
    public enum TouchState {
        case began
        case ended
    }
}

public typealias Control = BaseControl & ViewComposable
