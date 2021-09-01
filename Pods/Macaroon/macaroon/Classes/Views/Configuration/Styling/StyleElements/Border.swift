// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public struct Border {
    public let color: UIColor
    public let width: CGFloat

    public init(
        color: UIColor,
        width: CGFloat
    ) {
        self.color = color
        self.width = width
    }
}

public struct GradientBorder {
    public var isRounded: Bool {
        return
            !cornerRadii.isEmpty &&
            !corners.isEmpty
    }

    public let colors: [CGColor]
    public let width: CGFloat
    public let cornerRadii: CGSize
    public let corners: UIRectCorner

    public init(
        colors: [UIColor],
        width: CGFloat,
        cornerRadii: LayoutSize = (0, 0),
        corners: UIRectCorner = []
    ) {
        self.colors = colors.map(\.cgColor)
        self.width = width
        self.cornerRadii = CGSize(cornerRadii)
        self.corners = corners
    }
}
