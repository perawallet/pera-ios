// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

extension UIView.AnimationCurve {
    public func validate() -> Self? {
        switch self {
        case .easeIn,
             .easeInOut,
             .easeOut,
             .linear:
            return self
        default:
            return nil
        }
    }
}
