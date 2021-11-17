// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

public protocol BottomScrollOverlayContainer: Container {
    associatedtype ScrollFragment: BottomScrollOverlayFragment
    associatedtype StyleSheet: BottomScrollOverlayContainerStyleSheet
    associatedtype LayoutSheet: BottomScrollOverlayContainerLayoutSheet

    var styleSheet: StyleSheet { get }
    var layoutSheet: LayoutSheet { get }

    var scrollOverlayViewTopConstraint: Constraint! { get set }

    var lastScrollOverlayOffset: LayoutMetric { get set }
    var lastScrollOverlayTranslationOnScroll: LayoutMetric { get set }

    var runningScrollOverlayAnimator: UIViewPropertyAnimator? { get set }

    /// <note>
    /// Should contain the `scrollFragmentScreen.view` as the `contentView`.
    var scrollOverlayView: BottomOverlayView { get }
    var scrollFragmentScreen: ScrollFragment { get }

    func scrollOverlayWillMove(to position: BottomScrollOverlayPosition)
    func scrollOverlayDidMove(to position: BottomScrollOverlayPosition)
}

extension BottomScrollOverlayContainer {
    public var currentScrollOverlayOffset: LayoutMetric {
        return scrollOverlayView.frame.minY
    }
}

extension BottomScrollOverlayContainer {
    public func customizeScrollOverlayAppearance() {
        scrollOverlayView.customizeAppearance(
            styleSheet.scrollOverlay
        )
    }
}

extension BottomScrollOverlayContainer {
    public func addScrollOverlay() {
        addFragment(
            scrollFragmentScreen
        ) { _ in
            view.addSubview(
                scrollOverlayView
            )
            scrollOverlayView.prepareLayout(
                layoutSheet.scrollOverlay
            )
            scrollOverlayView.snp.makeConstraints {
                scrollOverlayViewTopConstraint = $0.top == 0

                $0.matchToHeight(
                    of: view
                )
                $0.setHorizontalPaddings(
                    layoutSheet.scrollOverlayHorizontalPaddings
                )
            }
        }
    }

    public func updateScrollOverlayLayoutWhenViewDidFirstLayoutSubviews() {
        scrollOverlayView.snp.updateConstraints {
            $0.matchToHeight(
                of: view,
                offset: -layoutSheet[.top]
            )
        }

        moveScrollOverlay(
            to: .bottom,
            withInitialVelocity: .zero,
            animated: false
        )
    }

    public func updateScrollFragmentLayoutWhenViewDidLayoutSubviews() {
        scrollFragmentScreen.isScrollEnabled = currentScrollOverlayOffset <= layoutSheet[.top]
    }
}

extension BottomScrollOverlayContainer {
    public func moveScrollOverlay(
        to position: BottomScrollOverlayPosition,
        withInitialVelocity velocity: CGVector,
        animated: Bool
    ) {
        scrollOverlayWillMove(
            to: position
        )

        let scrollOverlayOffsetAtPosition = layoutSheet[position]

        if scrollOverlayOffsetAtPosition == currentScrollOverlayOffset {
            return
        }

        discardRunningAnimationToMoveScrollOverlay()

        scrollOverlayViewTopConstraint.update(
            inset: scrollOverlayOffsetAtPosition
        )

        if !animated {
            return
        }

        startAnimationToMoveScrollOverlay(
            withInitialVelocity: velocity
        ) { [weak self] isCompleted in

            guard let self = self else {
                return
            }

            if !isCompleted {
                return
            }

            self.scrollOverlayDidMove(
                to: position
            )
        }
    }

    private func startAnimationToMoveScrollOverlay(
        withInitialVelocity velocity: CGVector,
        completion: @escaping (Bool) -> Void
    ) {
        let springTimingParameters =
            UISpringTimingParameters(dampingRatio: 0.8, initialVelocity: velocity)
        let animator =
            UIViewPropertyAnimator(duration: 0.5, timingParameters: springTimingParameters)
        animator.addAnimations {
            [unowned self] in

            self.view.layoutIfNeeded()
        }
        animator.isUserInteractionEnabled = true
        animator.isInterruptible = true
        animator.addCompletion {
            [weak self] state in

            guard let self = self else {
                return
            }

            self.runningScrollOverlayAnimator = nil

            completion(
                state == .end
            )
        }
        animator.startAnimation()

        runningScrollOverlayAnimator = animator
    }

    private func discardRunningAnimationToMoveScrollOverlay() {
        guard let animator = runningScrollOverlayAnimator else {
            return
        }

        animator.stopAnimation(
            false
        )
        animator.finishAnimation(
            at: .current
        )

        runningScrollOverlayAnimator = nil
    }
}

extension BottomScrollOverlayContainer {
    public func moveScrollOverlay(
        by panGestureRecognizer: UIPanGestureRecognizer
    ) {
        let translation =
            panGestureRecognizer.translation(
                in: panGestureRecognizer.view
            ).y

        if !scrollFragmentScreen.scrollView.isScrollAtTop {
            lastScrollOverlayOffset = currentScrollOverlayOffset
            lastScrollOverlayTranslationOnScroll = translation

            return
        }

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
        discardRunningAnimationToMoveScrollOverlay()

        lastScrollOverlayOffset = currentScrollOverlayOffset
        lastScrollOverlayTranslationOnScroll = 0
    }

    private func scrollGestureDidChange(
        _ panGestureRecognizer: UIPanGestureRecognizer,
        byTranslation translation: CGFloat
    ) {
        let dTranslation = translation - lastScrollOverlayTranslationOnScroll
        let preferredScrollOverlayOffset = lastScrollOverlayOffset + dTranslation
        let newScrollOverlayOffset =
            layoutSheet.clampScrollOverlayOffset(
                preferredScrollOverlayOffset
            )

        scrollOverlayViewTopConstraint.update(
            inset: newScrollOverlayOffset
        )

        lastScrollOverlayOffset = newScrollOverlayOffset
        lastScrollOverlayTranslationOnScroll = translation
    }

    private func scrollGestureDidComplete(
        _ panGestureRecognizer: UIPanGestureRecognizer
    ) {
        let newPosition =
            layoutSheet.nearestScrollOverlayPosition(
                atOffset: currentScrollOverlayOffset,
                movingBy: panGestureRecognizer
            )
        let distanceY = layoutSheet[newPosition] - currentScrollOverlayOffset
        let velocity =
            panGestureRecognizer.initialVelocityForSpringAnimation(
                forDistance: CGPoint(x: 0, y: distanceY),
                in: panGestureRecognizer.view
            )

        moveScrollOverlay(
            to: newPosition,
            withInitialVelocity: velocity,
            animated: true
        )

        lastScrollOverlayOffset = currentScrollOverlayOffset
        lastScrollOverlayTranslationOnScroll = 0
    }
}

public protocol BottomScrollOverlayContainerStyleSheet: StyleSheet {
    var scrollOverlay: BottomOverlayViewStyleSheet { get }
}

public protocol BottomScrollOverlayContainerLayoutSheet: LayoutSheet {
    var scrollOverlay: BottomOverlayViewLayoutSheet { get }
    var scrollOverlayHorizontalPaddings: LayoutHorizontalPaddings { get }

    subscript(pos: BottomScrollOverlayPosition) -> LayoutMetric { get }
}

extension BottomScrollOverlayContainerLayoutSheet {
    public func clampScrollOverlayOffset(
        _ preferredScrollOverlayOffset: CGFloat
    ) -> LayoutMetric {
        let minScrollOverlayOffset = self[.top]
        let maxScrollOverlayOffset = self[.bottom]

        return max(minScrollOverlayOffset, min(maxScrollOverlayOffset, preferredScrollOverlayOffset))
    }

    public func nearestScrollOverlayPosition(
        atOffset offset: LayoutMetric,
        movingBy panGestureRecognizer: UIPanGestureRecognizer
    ) -> BottomScrollOverlayPosition {
        let projectedOffset =
            panGestureRecognizer.project(
                pointY: offset,
                decelerationRate: UIScrollView.DecelerationRate.fast.rawValue
            )

        var scrollOverlayOffsetsPerPosition: [BottomScrollOverlayPosition: LayoutMetric] = [:]
        BottomScrollOverlayPosition.allCases.forEach {
            scrollOverlayOffsetsPerPosition[$0] = self[$0]
        }

        let preferredScrollOverlayPosition =
            scrollOverlayOffsetsPerPosition.min(
                by: {
                    abs($0.value - projectedOffset) < abs($1.value - projectedOffset)
                }
            )

        guard let somePreferredScrollOverlayPosition = preferredScrollOverlayPosition else {
            return .mid
        }

        let velocity =
            panGestureRecognizer.velocity(
                in: panGestureRecognizer.view
            ).y

        if (somePreferredScrollOverlayPosition.value - offset) * velocity >= 0 {
            return somePreferredScrollOverlayPosition.key
        }

        /// <note>
        /// if velocity is too low to change the current anchor, select the next anchor anyway.
        switch somePreferredScrollOverlayPosition.key {
        case .top: return velocity < 0 ?  .top : .mid
        case .mid: return velocity < 0 ? .top : .bottom
        case .bottom: return velocity < 0 ? .mid : .bottom
        }
    }
}

public enum BottomScrollOverlayPosition: CaseIterable {
    case top
    case mid
    case bottom
}
