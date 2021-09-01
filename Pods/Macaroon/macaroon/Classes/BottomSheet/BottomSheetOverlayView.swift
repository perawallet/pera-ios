// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

open class BottomSheetOverlayView:
    View,
    DoubleShadowDrawable {
    public var secondShadow: Shadow?

    public private(set) lazy var handleView = UIImageView()
    public private(set) lazy var secondShadowLayer = CAShapeLayer()

    open func customizeAppearance(
        _ styleSheet: BottomSheetOverlayViewStyleSheet
    ) {
        customizeAppearance(
            styleSheet.background
        )
        customizeHandleAppearance(
            styleSheet
        )

        drawAppearance(
            shadow: styleSheet.backgroundShadow
        )
        drawAppearance(
            secondShadow: styleSheet.backgroundSecondShadow
        )
    }

    open func resetShadowAppearance() {
        eraseShadow()
        eraseSecondShadow()
    }

    open func prepareLayout(
        _ layoutSheet: BottomSheetOverlayViewLayoutSheet
    ) {
        addHandle(
            layoutSheet
        )
    }

    open override func preferredUserInterfaceStyleDidChange() {
        super.preferredUserInterfaceStyleDidChange()

        drawAppearance(
            secondShadow: secondShadow
        )
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        guard let secondShadow = secondShadow else {
            return
        }

        updateOnLayoutSubviews(
            secondShadow: secondShadow
        )
    }
}

extension BottomSheetOverlayView {
    private func customizeHandleAppearance(
        _ styleSheet: BottomSheetOverlayViewStyleSheet
    ) {
        handleView.customizeAppearance(
            styleSheet.handle
        )
    }
}

extension BottomSheetOverlayView {
    private func addHandle(
        _ layoutSheet: BottomSheetOverlayViewLayoutSheet
    ) {
        addSubview(
            handleView
        )
        handleView.snp.makeConstraints {
            $0.centerHorizontally(
                offset: layoutSheet.handleCenterOffsetX,
                verticalPaddings: (layoutSheet.handleTopPadding, .noMetric)
            )
        }
    }
}

public struct BottomSheetOverlayViewStyleSheet: StyleSheet {
    public var background: ViewStyle
    public var backgroundShadow: Shadow?
    public var backgroundSecondShadow: Shadow?
    public var handle: ImageStyle

    public init() {
        self.background = []
        self.backgroundShadow = nil
        self.backgroundSecondShadow = nil
        self.handle = []
    }
}

public struct BottomSheetOverlayViewLayoutSheet: LayoutSheet {
    public var handleCenterOffsetX: LayoutMetric
    public var handleTopPadding: LayoutMetric

    public init(
        _ family: LayoutFamily
    ) {
        self.handleCenterOffsetX = 0
        self.handleTopPadding = 8
    }
}
