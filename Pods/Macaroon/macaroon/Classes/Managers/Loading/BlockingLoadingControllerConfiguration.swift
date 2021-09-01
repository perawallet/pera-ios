// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public struct BlockingLoadingControllerConfiguration {
    public var chromeStyle: ViewStyle

    public var loadingIndicatorMaxWidthRatio: LayoutMetric
    public var loadingIndicatorCenterOffsetY: LayoutMetric

    public var loadingIndicatorClass: LoadingIndicator.Type

    public init() {
        self.chromeStyle = [.backgroundColor(rgba(0, 0, 0, 0.5))]
        self.loadingIndicatorMaxWidthRatio = 0.4
        self.loadingIndicatorCenterOffsetY = 0
        self.loadingIndicatorClass = UIActivityIndicatorView.self
    }
}
