//
//  CGFloat+Additions.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

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
