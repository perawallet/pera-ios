// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

open class ImageView: UIImageView {
    open override var intrinsicContentSize: CGSize {
        return image == nil ? .zero : super.intrinsicContentSize
    }
}
