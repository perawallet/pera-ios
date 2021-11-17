// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol BorderDrawable: UIView {}

extension BorderDrawable {
    public func drawAppearance(
        border: Border?
    ) {
        guard let border = border else {
            eraseBorder()
            return
        }

        draw(
            border: border
        )
    }
}

extension BorderDrawable {
    public func draw(
        border: Border
    ) {
        layer.draw(
            border: border
        )
    }

    public func eraseBorder() {
        layer.draw(
            border: Border(color: .black, width: 0.0)
        )
    }
}

extension CALayer {
    public func draw(
        border: Border
    ) {
        borderColor = border.color.cgColor
        borderWidth = border.width
    }
}
