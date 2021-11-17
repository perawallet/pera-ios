// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import Kingfisher
import UIKit

public enum ImageSize {
    case original
    case resize(CGSize, ContentMode)
    case cropping(CGSize)
    case downsampling(CGSize)

    public func reduce() -> CGSize? {
        switch self {
        case .original:
            return nil
        case .resize(let size, _),
             .cropping(let size),
             .downsampling(let size):
            return size
        }
    }
}
