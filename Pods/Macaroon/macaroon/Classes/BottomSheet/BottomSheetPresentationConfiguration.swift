// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

public struct BottomSheetPresentationConfiguration: ModalPresentationConfiguration {
    public var chromeStyle: ViewStyle = [.backgroundColor(rgba(0, 0, 0, 0.8))]

    public var overlayStyleSheet = BottomSheetOverlayViewStyleSheet()
    public var overlayLayoutSheet = BottomSheetOverlayViewLayoutSheet()

    /// <note>
    /// The offset to show the handle bar over the presented content.
    public var overlayOffset: LayoutMetric = 16

    public init() {}
}
