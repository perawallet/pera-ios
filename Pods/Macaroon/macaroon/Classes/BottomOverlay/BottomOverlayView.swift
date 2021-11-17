// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

open class BottomOverlayView:
    View,
    DoubleShadowDrawable {
    public var secondShadow: Shadow?

    public private(set) lazy var handleView = UIImageView()
    public private(set) lazy var secondShadowLayer = CAShapeLayer()

    public let contentView: UIView

    public init(
        contentView: UIView
    ) {
        self.contentView = contentView

        super.init(
            frame: .zero
        )
    }

    open func customizeAppearance(
        _ styleSheet: BottomOverlayViewStyleSheet
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
        _ layoutSheet: BottomOverlayViewLayoutSheet
    ) {
        addContent(
            layoutSheet
        )
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

extension BottomOverlayView {
    private func customizeHandleAppearance(
        _ styleSheet: BottomOverlayViewStyleSheet
    ) {
        handleView.customizeAppearance(
            styleSheet.handle
        )
    }
}

extension BottomOverlayView {
    private func addContent(
        _ layoutSheet: BottomOverlayViewLayoutSheet
    ) {
        addSubview(
            contentView
        )
        contentView.snp.makeConstraints {
            $0.setPaddings(
                layoutSheet.contentPaddings
            )
        }
    }

    private func addHandle(
        _ layoutSheet: BottomOverlayViewLayoutSheet
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

public protocol BottomOverlayViewStyleSheet: StyleSheet {
    var background: ViewStyle { get }
    var backgroundShadow: Shadow? { get }
    var backgroundSecondShadow: Shadow? { get }
    var handle: ImageStyle { get }
}

public protocol BottomOverlayViewLayoutSheet: LayoutSheet {
    var contentPaddings: LayoutPaddings { get }
    var handleCenterOffsetX: LayoutMetric { get }
    var handleTopPadding: LayoutMetric { get }
}
