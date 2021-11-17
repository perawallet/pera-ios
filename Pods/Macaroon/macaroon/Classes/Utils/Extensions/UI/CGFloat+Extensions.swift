// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

extension CGFloat {
    public var isIntrinsicMetric: Bool {
        return self != UIView.noIntrinsicMetric
    }
}

extension CGFloat {
    public func ceil() -> CGFloat {
        return rounded(.up)
    }

    public func float() -> CGFloat {
        return rounded(.down)
    }
}

extension CGFloat {
    public func scaled(_ scale: CGFloat = UIScreen.main.scale) -> CGFloat {
        return self * scale
    }
}

extension CGFloat {
    public func projected(decelerationRate: UIScrollView.DecelerationRate) -> CGFloat {
        let factor = -1 / (1000 * log(decelerationRate.rawValue))
        return factor * self
    }
}
