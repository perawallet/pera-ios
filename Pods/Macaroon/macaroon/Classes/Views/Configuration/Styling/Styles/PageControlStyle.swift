// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public typealias PageControlStyle = BaseStyle<PageControlStyleAttribute>

public enum PageControlStyleAttribute: BaseStyleAttribute {
    /// <mark>
    /// Base
    case backgroundColor(Color)
    case tintColor(Color)

    /// <mark>
    /// PageControl
    case indicatorColor(Color)

    /// <warning>
    /// It has no effect below iOS 14.
    case indicatorImage(Image)
}

extension PageControlStyleAttribute {
    public var id: String {
        switch self {
        case .backgroundColor: return Self.getBackgroundColorAttributeId()
        case .tintColor: return Self.getTintColorAttributeId()
        case .indicatorColor: return "pageControl.indicatorColor"
        case .indicatorImage: return "pageControl.indicatorImage"
        }
    }
}
