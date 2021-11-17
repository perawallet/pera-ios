// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

extension CGSize {
    public init(
        _ layoutSize: LayoutSize
    ) {
        self.init(width: layoutSize.w, height: layoutSize.h)
    }
}

extension CGSize {
    public static var greatestFiniteMagnitude: CGSize {
        return CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    }

    public static var leastTouchMagnitude: CGSize {
        return CGSize(width: 44.0, height: 44.0)
    }
}

extension CGSize {
    public var isEmpty: Bool {
        return width == 0.0 && height == 0.0
    }

    public var isSquare: Bool {
        return width == height
    }

    public static func < (lhs: CGSize, rhs: CGSize) -> Bool {
        return lhs.width <= rhs.width && lhs.height <= rhs.height
    }

    public static func > (lhs: CGSize, rhs: CGSize) -> Bool {
        return lhs.width > rhs.width && lhs.height > rhs.height
    }
}

extension CGSize {
    public var minDimension: CGFloat {
        return min(width, height)
    }
    public var minSquare: CGSize {
        return CGSize(width: minDimension, height: minDimension)
    }

    public func scaled(_ scale: CGFloat = UIScreen.main.scale) -> CGSize {
        return CGSize(width: width * scale, height: height * scale)
    }
}

extension CGSize {
    public var aspectRatio: CGFloat {
        return width / height
    }
}
