// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

extension UIView {
    public var compactSafeAreaInsets: UIEdgeInsets {
        if let window = window {
            return window.safeAreaInsets
        }
        return UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
    }
}

extension UIView {
    public func layoutIfNeededInParent() {
        if window == nil {
            return
        }

        layoutIfNeeded()
    }
}

extension UIView {
    public func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
}

extension Array where Element: UIView {
    public mutating func removeFromSuperview() {
        forEach { $0.removeFromSuperview() }
        removeAll()
    }
}
