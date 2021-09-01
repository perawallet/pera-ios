// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

extension UIImage {
    public var original: UIImage {
        return withRenderingMode(.alwaysOriginal)
    }
    public var template: UIImage {
        return withRenderingMode(.alwaysTemplate)
    }
}

extension UIImage {
    public var width: CGFloat {
        return size.width
    }
    public var height: CGFloat {
        return size.height
    }
    public var aspectRatio: CGFloat {
        return size.aspectRatio
    }
}
