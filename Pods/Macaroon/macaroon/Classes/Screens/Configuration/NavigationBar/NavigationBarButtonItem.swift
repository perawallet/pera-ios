// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

public protocol NavigationBarButtonItem {
    var view: UIControl { get }
    var size: LayoutSize? { get }

    func add(target: Any, action: Selector)
}

extension NavigationBarButtonItem {
    public var size: LayoutSize? {
        return (40, 40)
    }

    public func add(
        target: Any,
        action: Selector
    ) {
        view.addTarget(
            target,
            action: action,
            for: .touchUpInside
        )
    }
}

extension NavigationBarButtonItem {
    public func asSystemBarButtonItem() -> UIBarButtonItem {
        if let size = size {
            view.snp.makeConstraints {
                $0.fitToSize(size)
            }
        }

        return UIBarButtonItem(customView: view)
    }
}
