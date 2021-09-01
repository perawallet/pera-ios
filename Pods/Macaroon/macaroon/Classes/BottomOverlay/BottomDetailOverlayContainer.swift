// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

public protocol BottomDetailOverlayContainer: Container {
    associatedtype DetailFragment: BottomDetailOverlayFragment
    associatedtype StyleSheet: BottomDetailOverlayContainerStyleSheet
    associatedtype LayoutSheet: BottomDetailOverlayContainerLayoutSheet

    var styleSheet: StyleSheet { get }
    var layoutSheet: LayoutSheet { get }

    var detailOverlayViewTopConstraint: Constraint! { get set }

    var initialDetailOverlayOffset: LayoutMetric { get set }

    var runningDetailOverlayAnimator: UIViewPropertyAnimator? { get set }

    /// <note>
    /// Should contain the `detailFragmentScreen.view` as the `contentView`.
    var detailOverlayView: BottomOverlayView { get }
    var detailFragmentScreen: DetailFragment { get }

    func detailOverlayViewWillBecomeVisible(_ isVisible: Bool)
    func detailOverlayViewDidBecomevisible(_ isVisible: Bool)
}

extension BottomDetailOverlayContainer {
    public var currentDetailOverlayOffset: LayoutMetric {
        return detailOverlayView.frame.minY
    }
}

extension BottomDetailOverlayContainer {
    public func customizeDetailOverlayAppearance() {
        detailOverlayView.customizeAppearance(
            styleSheet.detailOverlay
        )
    }
}

extension BottomDetailOverlayContainer {
    public func addDetailOverlay() {
        addFragment(
            detailFragmentScreen
        ) { _ in
            view.addSubview(
                detailOverlayView
            )
            detailOverlayView.prepareLayout(
                layoutSheet.detailOverlay
            )
            detailOverlayView.snp.makeConstraints {
                detailOverlayViewTopConstraint = $0.top == 0

                $0.setHorizontalPaddings(
                    layoutSheet.detailOverlayHorizontalPaddings
                )
            }
        }
    }

    public func updateDetailOverlayLayoutWhenViewDidFirstLayoutSubviews() {
        makeDetailOverlayVisible(
            false,
            withInitialVelocity: .zero,
            animated: false
        )
    }
}

extension BottomDetailOverlayContainer {
    public func makeDetailOverlayVisible(
        _ isVisible: Bool,
        withInitialVelocity velocity: CGVector,
        animated: Bool
    ) {
        detailOverlayView.layoutIfNeeded()

        detailOverlayViewWillBecomeVisible(
            isVisible
        )

        let finalDetailOverlayOffset =
            layoutSheet.finalDetailOverlayOffset(
                visible: isVisible,
                in: self
            )

        if finalDetailOverlayOffset == currentDetailOverlayOffset {
            return
        }

        discardRunningAnimationToChangeDetailOverlayVisibilty()

        detailOverlayViewTopConstraint.update(
            inset: finalDetailOverlayOffset
        )

        if !animated {
            return
        }

        startAnimationToChangeDetailOverlayVisibilty(
            withInitialVelocity: velocity
        ) { [weak self] isCompleted in

            guard let self = self else {
                return
            }

            if !isCompleted {
                return
            }

            self.detailOverlayViewDidBecomevisible(
                isVisible
            )

            self.initialDetailOverlayOffset = self.currentDetailOverlayOffset
        }
    }

    private func startAnimationToChangeDetailOverlayVisibilty(
        withInitialVelocity velocity: CGVector,
        completion: @escaping (Bool) -> Void
    ) {
        let springTimingParameters =
            UISpringTimingParameters(dampingRatio: 0.95, initialVelocity: velocity)
        let animator =
            UIViewPropertyAnimator(duration: 0.5, timingParameters: springTimingParameters)
        animator.addAnimations {
            [unowned self] in

            self.view.layoutIfNeeded()
        }
        animator.isUserInteractionEnabled = false
        animator.isInterruptible = true
        animator.addCompletion {
            [weak self] state in

            guard let self = self else {
                return
            }

            self.runningDetailOverlayAnimator = nil

            completion(
                state == .end
            )
        }
        animator.startAnimation()

        runningDetailOverlayAnimator = animator
    }

    private func discardRunningAnimationToChangeDetailOverlayVisibilty() {
        guard let animator = runningDetailOverlayAnimator else {
            return
        }

        animator.stopAnimation(
            false
        )
        animator.finishAnimation(
            at: .current
        )

        runningDetailOverlayAnimator = nil
    }
}

extension BottomDetailOverlayContainer {
    public func moveDetailOverlay(
        by panGestureRecognizer: UIPanGestureRecognizer
    ) {
        let translation =
            panGestureRecognizer.translation(
                in: panGestureRecognizer.view
            ).y

        switch panGestureRecognizer.state {
        case .began:
            scrollGestureDidBegin(
                panGestureRecognizer
            )
        case .changed:
            scrollGestureDidChange(
                panGestureRecognizer,
                byTranslation: translation
            )
        case .ended,
             .failed,
             .cancelled:
            scrollGestureDidComplete(
                panGestureRecognizer
            )
        default: break
        }
    }

    private func scrollGestureDidBegin(
        _ panGestureRecognizer: UIPanGestureRecognizer
    ) {
        discardRunningAnimationToChangeDetailOverlayVisibilty()
        initialDetailOverlayOffset = currentDetailOverlayOffset
    }

    private func scrollGestureDidChange(
        _ panGestureRecognizer: UIPanGestureRecognizer,
        byTranslation translation: CGFloat
    ) {
        let preferredDetailOverlayOffset =
            initialDetailOverlayOffset + translation
        let detailOverlayOffset =
            layoutSheet.clampDetailOverlayOffset(
                preferredDetailOverlayOffset,
                movingBy: panGestureRecognizer,
                in: self
            )

        detailOverlayViewTopConstraint.update(
            inset: detailOverlayOffset
        )
    }

    private func scrollGestureDidComplete(
        _ panGestureRecognizer: UIPanGestureRecognizer
    ) {
        let minDetailOverlayOffset =
            layoutSheet.finalDetailOverlayOffset(
                visible: true,
                in: self
            )
        let nearestDetailOverlayOffset =
            layoutSheet.nearestDetailOverlayOffset(
                atOffset: currentDetailOverlayOffset,
                movingBy: panGestureRecognizer,
                in: self
            )
        let distanceY = nearestDetailOverlayOffset - currentDetailOverlayOffset
        let isRubbingBand = currentDetailOverlayOffset < minDetailOverlayOffset
        let velocity =
            panGestureRecognizer.initialVelocityForSpringAnimation(
                forDistance: CGPoint(x: 0, y: isRubbingBand ? -distanceY : distanceY),
                in: panGestureRecognizer.view
            )

        makeDetailOverlayVisible(
            nearestDetailOverlayOffset == minDetailOverlayOffset,
            withInitialVelocity: velocity,
            animated: true
        )
    }
}

public protocol BottomDetailOverlayContainerStyleSheet: StyleSheet {
    var detailOverlay: BottomOverlayViewStyleSheet { get }
}

public protocol BottomDetailOverlayContainerLayoutSheet: LayoutSheet {
    var detailOverlay: BottomOverlayViewLayoutSheet { get }
    var detailOverlayHorizontalPaddings: LayoutHorizontalPaddings { get }
}

extension BottomDetailOverlayContainerLayoutSheet {
    public func finalDetailOverlayOffset<T: BottomDetailOverlayContainer>(
        visible: Bool,
        in screen: T
    ) -> LayoutMetric {
        let maxOffset = screen.view.bounds.height
        return visible ? maxOffset - screen.detailOverlayView.bounds.height : maxOffset
    }

    public func clampDetailOverlayOffset<T: BottomDetailOverlayContainer>(
        _ preferredDetailOverlayOffset: LayoutMetric,
        movingBy panGestureRecognizer: UIPanGestureRecognizer,
        in screen: T
    ) -> LayoutMetric {
        let minDetailOverlayOffset =
            finalDetailOverlayOffset(
                visible: true,
                in: screen
            )

        if preferredDetailOverlayOffset >= minDetailOverlayOffset {
            return preferredDetailOverlayOffset
        }

        let rubberBandTranslation =
            panGestureRecognizer.rubberBandTranslation(
                forDifference: minDetailOverlayOffset - preferredDetailOverlayOffset,
                dimmingAt: minDetailOverlayOffset * 0.1
            )

        return minDetailOverlayOffset - rubberBandTranslation
    }

    public func nearestDetailOverlayOffset<T: BottomDetailOverlayContainer>(
        atOffset offset: LayoutMetric,
        movingBy panGestureRecognizer: UIPanGestureRecognizer,
        in screen: T
    ) -> LayoutMetric {
        let projectedOffset =
            panGestureRecognizer.project(
                pointY: offset,
                decelerationRate: UIScrollView.DecelerationRate.fast.rawValue
            )
        let minOffset =
            finalDetailOverlayOffset(
                visible: true,
                in: screen
            )
        let maxOffset =
            finalDetailOverlayOffset(
                visible: false,
                in: screen
            )
        let preferredOffset =
            [minOffset, maxOffset].min {
                abs($0 - projectedOffset) < abs($1 - projectedOffset)
            }

        guard let somePreferredOffset = preferredOffset else {
            return maxOffset
        }

        let velocity =
            panGestureRecognizer.velocity(
                in: panGestureRecognizer.view
            ).y

        if (somePreferredOffset - offset) * velocity >= 0 {
            return somePreferredOffset
        }

        /// <note>
        /// if velocity is too low to change the current anchor, select the next anchor anyway.
        return velocity < 0 ? minOffset : maxOffset
    }
}
