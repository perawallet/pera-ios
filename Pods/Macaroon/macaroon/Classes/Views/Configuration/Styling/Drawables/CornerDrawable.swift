// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol CornerDrawable: UIView {}

extension CornerDrawable {
    public func drawAppearance(
        corner: Corner?
    ) {
        guard let corner = corner else {
            eraseCorner()
            return
        }

        draw(
            corner: corner
        )
    }
}

extension CornerDrawable {
    public func draw(
        corner: Corner
    ) {
        layer.draw(
            corner: corner
        )

        if layer.shadowOpacity == 0 {
            layer.masksToBounds = true
        }
    }

    public func eraseCorner() {
        layer.draw(
            corner: Corner(radius: 0.0)
        )
    }
}

extension CALayer {
    public func draw(
        corner: Corner
    ) {
        cornerRadius = corner.radius
        maskedCorners = corner.mask
    }
}
