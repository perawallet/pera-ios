// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

open class ModalAnimator:
    NSObject,
    UIViewControllerAnimatedTransitioning {
    public var presentingDuration: TimeInterval = 0.5
    public var presentingAnimationMode: AnimationMode = .spring()

    public var dismissingDuration: TimeInterval = 0.2
    public var dismissingAnimationMode: AnimationMode = .normal(curve: .linear)

    public var ongoingInterruptibleAnimator: UIViewImplicitlyAnimating?

    public let isPresenting: Bool

    public init(
        isPresenting: Bool
    ) {
        self.isPresenting = isPresenting
        super.init()
    }

    open func willAnimatePresenting(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        guard let presentedView = transitionContext.destinationView else {
            return
        }

        transitionContext.containerView.addSubview(
            presentedView
        )
        presentedView.frame =
            calculatePresentedInitalFrameOnPresenting(
                using: transitionContext
            )
    }

    open func animate(
        alongsidePresenting transitionContext: UIViewControllerContextTransitioning
    ) {
        guard
            let presentedView = transitionContext.destinationView,
            let presentedFinalFrame = transitionContext.destinationFinalFrame
        else {
            return
        }

        presentedView.frame = presentedFinalFrame
    }

    open func didAnimatePresenting(
        using transitionContext: UIViewControllerContextTransitioning
    ) {}

    open func willAnimateDismissing(
        using transitionContext: UIViewControllerContextTransitioning
    ) {}

    open func animate(
        alongsideDismissing transitionContext: UIViewControllerContextTransitioning
    ) {
        guard let presentedView = transitionContext.sourceView else {
            return
        }

        presentedView.frame =
            calculatePresentedFinalFrameOnDismissing(
                using: transitionContext
            )
    }

    open func didAnimateDismissing(
        using transitionContext: UIViewControllerContextTransitioning
    ) {}

    open func calculatePresentedInitalFrameOnPresenting(
        using transitionContext: UIViewControllerContextTransitioning
    ) -> CGRect {
        mc_crash(
            .shouldBeImplementedBySubclass(functionName: #function)
        )
    }

    open func calculatePresentedFinalFrameOnDismissing(
        using transitionContext: UIViewControllerContextTransitioning
    ) -> CGRect {
        mc_crash(
            .shouldBeImplementedBySubclass(functionName: #function)
        )
    }

    /// <mark>
    /// UIViewControllerAnimatedTransitioning
    open func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return isPresenting ? presentingDuration : dismissingDuration
    }

    open func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        if isPresenting {
            willAnimatePresenting(
                using: transitionContext
            )
        } else {
            willAnimateDismissing(
                using: transitionContext
            )
        }

        let animator =
            interruptibleAnimator(
                using: transitionContext
            )
        animator.startAnimation()
    }

    open func interruptibleAnimator(
        using transitionContext: UIViewControllerContextTransitioning
    ) -> UIViewImplicitlyAnimating {
        if let ongoingInterruptibleAnimator = ongoingInterruptibleAnimator {
            return ongoingInterruptibleAnimator
        }

        let duration: TimeInterval
        let animationMode: AnimationMode
        let animations: () -> Void

        if isPresenting {
            duration = presentingDuration
            animationMode = presentingAnimationMode
            animations = {
                [unowned self] in

                self.animate(
                    alongsidePresenting: transitionContext
                )
            }
        } else {
            duration = dismissingDuration
            animationMode = dismissingAnimationMode
            animations = {
                [unowned self] in

                self.animate(
                    alongsideDismissing: transitionContext
                )
            }
        }

        let interruptibleAnimator: UIViewPropertyAnimator

        switch animationMode {
        case .normal(let curve):
            interruptibleAnimator =
                UIViewPropertyAnimator(
                    duration: duration,
                    curve: curve,
                    animations: animations
                )
        case .spring(let dampingRatio):
            interruptibleAnimator =
                UIViewPropertyAnimator(
                    duration: duration,
                    dampingRatio: dampingRatio,
                    animations: animations
                )
        }

        interruptibleAnimator.addCompletion {
            [weak self] _ in

            guard let self = self else {
                return
            }

            self.ongoingInterruptibleAnimator = nil

            if self.isPresenting {
                self.didAnimatePresenting(
                    using: transitionContext
                )
            } else {
                self.didAnimateDismissing(
                    using: transitionContext
                )
            }

            transitionContext.completeTransition(
                !transitionContext.transitionWasCancelled
            )
        }

        self.ongoingInterruptibleAnimator = interruptibleAnimator

        return interruptibleAnimator
    }
}

extension ModalAnimator {
    public enum AnimationMode {
        case normal(curve: UIView.AnimationCurve = .linear)
        case spring(dampingRatio: CGFloat = 0.8)
    }
}
