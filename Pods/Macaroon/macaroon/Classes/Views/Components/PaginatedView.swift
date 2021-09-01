// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

open class PaginatedView: View {
    public var contentEdgeInsets: LayoutPaddings = (0, 0, 0, 0) {
        didSet { updateLayoutWhenContentEdgeInsetsDidChange() }
    }

    public let scrollView: UIScrollView

    public init(
        _ scrollView: UIScrollView
    ) {
        self.scrollView = scrollView

        super.init(
            frame: .zero
        )

        customizeAppearance(
            NoStyleSheet()
        )
        prepareLayout(
            NoLayoutSheet()
        )
        linkInteractors()
    }

    open func customizeAppearance(
        _ styleSheet: StyleSheet
    ) {
        scrollView.isPagingEnabled = true
        scrollView.clipsToBounds = false
    }

    open func prepareLayout(
        _ layoutSheet: LayoutSheet
    ) {
        addScroll()
    }

    open func updateLayoutWhenContentEdgeInsetsDidChange() {
        updateScrollLayoutWhenContentEdgeInsetsDidChange()
    }

    open func addScroll() {
        addSubview(
            scrollView
        )
        scrollView.snp.makeConstraints {
            $0.setPaddings(
                contentEdgeInsets
            )
        }
    }

    open func updateScrollLayoutWhenContentEdgeInsetsDidChange() {
        scrollView.snp.updateConstraints {
            $0.setPaddings(
                contentEdgeInsets
            )
        }
    }

    public func linkInteractors() {
        addGestureRecognizer(
            scrollView.panGestureRecognizer
        )
    }
}
