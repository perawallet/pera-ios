//
//  CGFloat+Additions.swift

import CoreGraphics
import UIKit

extension CGFloat {
    var isIntrinsicMetric: Bool {
        return self != UIView.noIntrinsicMetric
    }
    
    var upper: CGFloat {
        return rounded(.up)
    }
    
    var lower: CGFloat {
        return rounded(.down)
    }
    
    var nearest: CGFloat {
        return rounded()
    }
}
