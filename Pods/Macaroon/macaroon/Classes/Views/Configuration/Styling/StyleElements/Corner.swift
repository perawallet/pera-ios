// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public struct Corner:
    ExpressibleByFloatLiteral,
    ExpressibleByIntegerLiteral {
    public let radius: CGFloat
    public let mask: CACornerMask

    public init(
        radius: CGFloat,
        mask: CACornerMask = [
            .layerMinXMinYCorner,
            .layerMinXMaxYCorner,
            .layerMaxXMinYCorner,
            .layerMaxXMaxYCorner
        ]
    ) {
        self.radius = radius
        self.mask = mask
    }

    public init(floatLiteral value: FloatLiteralType) {
        self.init(radius: CGFloat(value))
    }

    public init(integerLiteral value: IntegerLiteralType) {
        self.init(radius: CGFloat(value))
    }
}
