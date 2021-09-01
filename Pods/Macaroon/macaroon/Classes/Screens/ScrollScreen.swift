// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

open class ScrollScreen:
    Screen,
    UIScrollViewDelegate {
    public var blursFooterBackgroundOnUnderScrolling = false

    public private(set) lazy var scrollView = ScrollView()
    public private(set) lazy var contentView = UIView()
    public private(set) lazy var footerView = UIView()

    private lazy var footerBackgroundView = UIView()
    private lazy var footerBlurBackgroundView: UIVisualEffectView = {
        let view = UIVisualEffectView()

        if #available(iOS 13, *) {
            view.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        } else {
            view.effect = UIBlurEffect(style: .regular)
        }

        return view
    }()

    private var isScrollLayoutFinalized = false

    open func customizeScrollAppearance() {
        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
    }

    open func addScroll() {
        view.addSubview(
            scrollView
        )
        scrollView.snp.makeConstraints {
            $0.setPaddings(
                (0, 0, 0, 0)
            )
        }

        addContent()
    }

    open func updateScrollLayoutWhenViewDidLayoutSubviews() {
        if footerView.bounds.isEmpty {
            return
        }

        scrollView.setContentInset(
            bottom: footerView.bounds.height
        )
    }

    open func addContent() {
        scrollView.addSubview(
            contentView
        )
        contentView.snp.makeConstraints {
            $0.width == view

            $0.setPaddings(
                (0, 0, 0, 0)
            )
        }
    }

    open func addFooter() {
        view.addSubview(
            footerBackgroundView
        )
        footerBackgroundView.snp.makeConstraints {
            $0.setPaddings(
                (.noMetric, 0, 0, 0)
            )
        }

        footerBackgroundView.addSubview(
            footerView
        )
        footerView.snp.makeConstraints {
            $0.setPaddings(
                (0, 0, .noMetric, 0)
            )
            $0.setBottomPadding(
                0,
                inSafeAreaOf: footerBackgroundView
            )
        }
    }

    open override func customizeAppearance() {
        super.customizeAppearance()
        customizeScrollAppearance()
    }

    open override func prepareLayout() {
        super.prepareLayout()

        addScroll()
        addFooter()
    }

    open override func updateLayoutWhenViewDidLayoutSubviews() {
        super.updateLayoutWhenViewDidLayoutSubviews()

        if contentView.bounds.isEmpty {
            return
        }

        updateScrollLayoutWhenViewDidLayoutSubviews()
        updateLayoutOnScroll()
    }

    open override func setListeners() {
        super.setListeners()
        scrollView.delegate = self
    }

    /// <mark>
    /// UIScrollViewDelegate
    open func scrollViewDidScroll(
        _ scrollView: UIScrollView
    ) {
        updateLayoutOnScroll()
    }
}

extension ScrollScreen {
    private func updateLayoutOnScroll() {
        updateFooterBackgroundLayoutOnScroll()
    }

    private func addFooterBlurBackground() {
        if footerBlurBackgroundView.isDescendant(
            of: footerBackgroundView
        ) {
            return
        }

        footerBackgroundView.insertSubview(
            footerBlurBackgroundView,
            at: 0
        )
        footerBlurBackgroundView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    private func updateFooterBackgroundLayoutOnScroll() {
        if !blursFooterBackgroundOnUnderScrolling {
            return
        }

        if footerView.bounds.isEmpty {
            return
        }

        addFooterBlurBackground()

        let endOfContent = contentView.frame.maxY - scrollView.contentOffset.y
        footerBlurBackgroundView.isHidden = endOfContent <= footerBackgroundView.frame.minY
    }
}
