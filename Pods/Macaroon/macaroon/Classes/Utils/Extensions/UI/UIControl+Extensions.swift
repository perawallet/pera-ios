// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

extension UIControl {
    public func addTouch(
        target: Any,
        action: Selector
    ) {
        addTarget(
            target,
            action: action,
            for: .touchUpInside
        )
    }
}
