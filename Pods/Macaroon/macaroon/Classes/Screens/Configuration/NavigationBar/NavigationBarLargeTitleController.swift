// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

open class NavigationBarLargeTitleController<SomeScreen: NavigationBarLargeTitleConfigurable> {
    public var title: String? {
        didSet { setNeedsTitleAppearanceUpdate() }
    }

    public var titleAttributes: [AttributedTextBuilder.Attribute] = []
    public var largeTitleAttributes: [AttributedTextBuilder.Attribute] = []

    public unowned let screen: SomeScreen

    private var scrollingObservation: NSKeyValueObservation?
    private var runningTitleVisibilityAnimator: UIViewPropertyAnimator?

    private var minContentOffsetYForVisibleLargeTitle: CGFloat {
        let scrollView = screen.navigationBarScrollView
        let largeTitleView = screen.navigationBarLargeTitleView

        if !largeTitleView.isDescendant(
               of: scrollView
            ) {
            return -largeTitleView.scrollEdgeOffset
        }

        return
            largeTitleView.frame.maxY -
            largeTitleView.scrollEdgeOffset
    }

    private var isTitleVisible: Bool {
        return screen.navigationBarTitleView.titleAlpha == 1
    }

    public init(
        screen: SomeScreen
    ) {
        self.screen = screen
    }

    deinit {
        deactivate()
    }
}

extension NavigationBarLargeTitleController {
    public func setNeedsTitleAppearanceUpdate() {
        screen.navigationBarTitleView.title =
            title.unwrap {
                .attributedString(
                    $0.attributed(
                        titleAttributes
                    )
                )
            }
        screen.navigationBarLargeTitleView.title =
            title.unwrap {
                .attributedString(
                    $0.attributed(
                        largeTitleAttributes
                    )
                )
            }

        screen.navigationItem.titleView = screen.navigationBarTitleView
    }
}

extension NavigationBarLargeTitleController {
    public func activate() {
        scrollingObservation =
            screen.navigationBarScrollView.observe(
                \.contentOffset,
                options: .new
            ) { [weak self] _, change in

                guard let self = self else {
                    return
                }

                let contentOffsetY = change.newValue?.y ?? 0

                self.updateLargeTitleLayoutIfNeeded(
                    forScrollAtPoint: contentOffsetY)
                self.toggleTitleVisibilityIfNeeded(
                    forScrollAtPoint: contentOffsetY,
                    animated: self.screen.isViewAppeared
                )
            }
    }

    public func deactivate() {
        scrollingObservation?.invalidate()
        scrollingObservation = nil
    }
}

extension NavigationBarLargeTitleController {
    public func scrollViewWillEndDragging(
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>,
        contentOffsetDeltaYBelowLargeTitle: CGFloat
    ) {
        let largeTitleView = screen.navigationBarLargeTitleView
        let contentOffset = targetContentOffset.pointee

        if contentOffset.y > minContentOffsetYForVisibleLargeTitle {
            return
        }

        targetContentOffset.pointee =
            CGPoint(
                x: contentOffset.x,
                y: min(contentOffset.y, contentOffset.y + largeTitleView.frame.minY)
            )
    }
}

extension NavigationBarLargeTitleController {
    private func updateLargeTitleLayoutIfNeeded(
        forScrollAtPoint point: CGFloat
    ) {
        let scrollView = screen.navigationBarScrollView
        let largeTitleView = screen.navigationBarLargeTitleView

        if largeTitleView.isDescendant(
               of: scrollView
           ) {
            return
        }

        largeTitleView.snp.updateConstraints {
            $0.top == -(point + scrollView.contentInset.top)
        }
    }
}

extension NavigationBarLargeTitleController {
    private func toggleTitleVisibilityIfNeeded(
        forScrollAtPoint point: CGFloat,
        animated: Bool
    ) {
        let largeTitleView = screen.navigationBarLargeTitleView
        let isLargeTitleVisible =
            point <= minContentOffsetYForVisibleLargeTitle
        let isTitleVisible = !isLargeTitleVisible

        if self.isTitleVisible == isTitleVisible {
            return
        }

        discardRunningAnimationToToggleTitleVisibility()

        if !animated {
            setTitleVisible(
                isTitleVisible
            )

            return
        }

        startAnimationToToggleTitleVisibility(
            visible: isTitleVisible
        )
    }

    private func startAnimationToToggleTitleVisibility(
        visible: Bool
    ) {
        runningTitleVisibilityAnimator =
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: visible ? 0.2 : 0.1,
                delay: 0.0,
                options: visible ? [] : .curveEaseOut,
                animations: {
                    [unowned self] in

                    self.setTitleVisible(
                        visible
                    )
                },
                completion: {
                    [weak self] _ in

                    guard let self = self else {
                        return
                    }

                    self.runningTitleVisibilityAnimator = nil
                }
            )
    }

    private func discardRunningAnimationToToggleTitleVisibility() {
        runningTitleVisibilityAnimator?.stopAnimation(
            false
        )
        runningTitleVisibilityAnimator?.finishAnimation(
            at: .current
        )
        runningTitleVisibilityAnimator = nil
    }

    private func setTitleVisible(
        _ visible: Bool
    ) {
        screen.navigationBarTitleView.titleAlpha = visible ? 1 : 0
        screen.navigationBarLargeTitleView.alpha = visible ? 0 : 1
    }
}
