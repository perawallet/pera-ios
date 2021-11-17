// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public struct BannerControllerConfiguration {
    public var contentHorizontalPaddings: LayoutHorizontalPaddings = (16, 16)

    /// <note>
    /// It will be used to place the banners from the top edge of the screen, not safe area.
    public var contentTopPadding: LayoutMetric = 32

    public var contentStackSpacing: LayoutMetric = 8

    public var minAutoDissmissDuration: TimeInterval = 2

    public init() {}
}
