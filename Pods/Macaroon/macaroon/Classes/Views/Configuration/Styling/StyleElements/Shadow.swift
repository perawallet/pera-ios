// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public struct Shadow {
    public var isRounded: Bool {
        return
            !cornerRadii.isEmpty &&
            !corners.isEmpty
    }

    public var cornerRadius: CGFloat {
        return max(cornerRadii.width, cornerRadii.height)
    }
    public var maskedCorners: CACornerMask {
        var convertedMaskedCorners: CACornerMask = []

        if corners.contains(.topLeft) {
            convertedMaskedCorners.insert(
                .layerMinXMinYCorner
            )
        }
        if corners.contains(.topRight) {
            convertedMaskedCorners.insert(
                .layerMaxXMinYCorner
            )
        }
        if corners.contains(.bottomLeft) {
            convertedMaskedCorners.insert(
                .layerMinXMaxYCorner
            )
        }
        if corners.contains(.bottomRight) {
            convertedMaskedCorners.insert(
                .layerMaxXMaxYCorner
            )
        }

        return convertedMaskedCorners
    }

    public let color: UIColor
    public let opacity: Float
    public let offset: CGSize
    public let radius: CGFloat
    public let fillColor: UIColor?
    public let cornerRadii: CGSize
    public let corners: UIRectCorner
    public let shouldRasterize: Bool

    public init(
        color: UIColor,
        opacity: Float,
        offset: LayoutSize,
        radius: CGFloat,
        fillColor: UIColor?,
        cornerRadii: LayoutSize = (0, 0),
        corners: UIRectCorner = [],
        shouldRasterize: Bool = false
    ) {
        self.color = color
        self.opacity = opacity
        self.offset = CGSize(offset)
        self.radius = radius
        self.fillColor = fillColor
        self.cornerRadii = CGSize(cornerRadii)
        self.corners = corners
        self.shouldRasterize = shouldRasterize
    }
}
