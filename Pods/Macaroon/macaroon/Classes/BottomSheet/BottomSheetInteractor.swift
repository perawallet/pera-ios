// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

open class BottomSheetInteractor:
    NSObject,
    UIViewControllerInteractiveTransitioning {
    public var inProgress = false

    public weak var interactiveTransitionContext: UIViewControllerContextTransitioning?
    public weak var presentedViewController: UIViewController?

    public var presentedFrame: CGRect?
    public var completeTranslationY: CGFloat?
    public var lastInterruptedTranslationY: CGFloat = 0

    public var completion: (() -> Void)?

    public private(set) var ongoingCancelAnimator: UIViewPropertyAnimator?

    public unowned let presentingViewController: UIViewController

    private var disabledPresentedSubviewsAlongsideTransition: WeakArray<UIView> = []

    private var additionalAnimationsAlongsideTransition: ((CGFloat) -> Void)?
    private var additionalCompletionAfterTransition: ((Bool) -> Void)?

    public init(
        presentingViewController: UIViewController,
        completion: (() -> Void)? = nil
    ) {
        self.presentingViewController = presentingViewController
        self.completion = completion

        super.init()
    }

    open func createInteractiveGestureRecognizer() -> UIPanGestureRecognizer {
        return UIPanGestureRecognizer(target: self, action: #selector(handleInteractiveGesture(_:)))
    }

    open func createInteractiveScrollingGestureRecognizer() -> OneDirectionPanGestureRecognizer {
        return
            OneDirectionPanGestureRecognizer(
                direction: .down,
                target: self,
                action: #selector(handleInteractiveGesture(_:))
            )
    }

    open func startInteractiveTransition(
        _ transitionContext: UIViewControllerContextTransitioning
    ) {
        interactiveTransitionContext = transitionContext
        presentedViewController = transitionContext.sourceViewController
        presentedFrame = transitionContext.sourceFinalFrame
        completeTranslationY = transitionContext.containerView.bounds.height - presentedFrame!.minY
    }

    open func updateInteractiveTransition(
        progress: CGFloat
    ) {
        guard let transitionContext = interactiveTransitionContext else {
            return
        }

        transitionContext.updateInteractiveTransition(
            progress
        )

        guard
            let presentedViewController = presentedViewController,
            let presentedFrame = presentedFrame
        else {
            return
        }

        let offsetY =
            completeTranslationY.unwrap(
                {
                    $0 * progress
                },
                or: 0
            )

        presentedViewController.view.frame =
            CGRect(
                origin: CGPoint(x: presentedFrame.minX, y: presentedFrame.minY + offsetY),
                size: presentedFrame.size
            )

        additionalAnimationsAlongsideTransition?(progress)
    }

    open func cancelInteractiveTransition(
        initialVelocity: CGVector
    ) {
        guard
            let transitionContext = interactiveTransitionContext,
            let presentedViewController = presentedViewController,
            let presentedFrame = presentedFrame
        else {
            return
        }

        let springTimingParameters =
            UISpringTimingParameters(dampingRatio: 0.65, initialVelocity: initialVelocity)

        let cancelAnimator =
            UIViewPropertyAnimator(duration: 0.25, timingParameters: springTimingParameters)
        cancelAnimator.addAnimations {
            [unowned self] in

            presentedViewController.view.frame = presentedFrame

            self.additionalAnimationsAlongsideTransition?(0)

        }
        cancelAnimator.addCompletion {
            [unowned self] _ in

            transitionContext.cancelInteractiveTransition()
            transitionContext.completeTransition(
                false
            )

            self.ongoingCancelAnimator = nil
            self.inProgress = false

            self.additionalCompletionAfterTransition?(
                true
            )

            self.enableTouchesAlongsideInteractiveTransition()
        }

        cancelAnimator.startAnimation()

        self.ongoingCancelAnimator = cancelAnimator
    }

    open func finishInteractiveTransition(
        initialVelocity: CGVector
    ) {
        guard
            let transitionContext = interactiveTransitionContext,
            let presentedViewController = presentedViewController,
            let presentedFrame = presentedFrame
        else {
            return
        }

        let dismissedFrame =
            CGRect(
                origin: CGPoint(x: presentedFrame.minX, y: transitionContext.containerView.bounds.height),
                size: presentedFrame.size
            )
        let springTimingParameters =
            UISpringTimingParameters(dampingRatio: 0.8, initialVelocity: initialVelocity)

        let finishAnimator =
            UIViewPropertyAnimator(duration: 0.4, timingParameters: springTimingParameters)
        finishAnimator.addAnimations {
            [unowned self] in

            presentedViewController.view.frame = dismissedFrame

            self.additionalAnimationsAlongsideTransition?(1)
        }
        finishAnimator.addCompletion {
            [unowned self] _ in

            transitionContext.finishInteractiveTransition()
            transitionContext.completeTransition(
                true
            )

            self.inProgress = false

            self.additionalCompletionAfterTransition?(
                false
            )
            self.completion?()
        }

        finishAnimator.startAnimation()
    }

    open func interactiveGestureDidBegin(
        _ panGestureRecognizer: UIPanGestureRecognizer
    ) {
        disableTouchesAlongsideInteractiveTransition()
        discardOngoingCancelAnimation()

        if let presentedViewController = presentedViewController,
           let presentedFrame = presentedFrame {
            lastInterruptedTranslationY =
                presentedViewController.view.frame.minY - presentedFrame.minY
        }

        if !inProgress {
            inProgress = true

            presentingViewController.dismiss(
                animated: true
            )
        }
    }

    open func interactiveGestureDidChange(
        _ panGestureRecognizer: UIPanGestureRecognizer,
        byTranslation translationY: CGFloat
    ) {
        guard let completeTranslationY = completeTranslationY else {
            updateInteractiveTransition(
                progress: 0
            )

            return
        }

        var progress = translationY / completeTranslationY

        if progress < 0 {
            let rubberBandTranslationY =
                panGestureRecognizer.rubberBandTranslation(
                    forDifference: -translationY,
                    dimmingAt: completeTranslationY * 0.1
                )
            let rubberBandProgress = rubberBandTranslationY / completeTranslationY

            progress = progress * rubberBandProgress
        }

        updateInteractiveTransition(
            progress: progress
        )
    }

    open func interactiveGestureDidCancel(
        _ panGestureRecognizer: UIPanGestureRecognizer,
        byTranslation translationY: CGFloat
    ) {
        let animationVelocity =
            panGestureRecognizer.initialVelocityForSpringAnimation(
                forDistance: CGPoint(x: 0, y: -translationY),
                in: panGestureRecognizer.view
            )
        cancelInteractiveTransition(
            initialVelocity: animationVelocity
        )
    }

    open func interactiveGestureDidEnd(
        _ panGestureRecognizer: UIPanGestureRecognizer,
        byTranslation translationY: CGFloat
    ) {
        let velocityY =
            panGestureRecognizer.velocity(
                in: panGestureRecognizer.view
            ).y
        let isInteractionEnoughToEnd: Bool

        if velocityY > 300 {
            isInteractionEnoughToEnd = true
        } else if velocityY > -300 {
            let minTranslationY =
                completeTranslationY.unwrap(
                    {
                        $0 / 2
                    },
                    or: 0
                )
            isInteractionEnoughToEnd = translationY > minTranslationY
        } else {
            isInteractionEnoughToEnd = false
        }

        if !isInteractionEnoughToEnd {
            interactiveGestureDidCancel(
                panGestureRecognizer,
                byTranslation: translationY
            )

            return
        }

        let animationVelocity =
            panGestureRecognizer.initialVelocityForSpringAnimation(
                forDistance: completeTranslationY.unwrap(
                    {
                        CGPoint(x: 0, y: $0 - translationY)
                    },
                    or: .zero
                ),
                in: panGestureRecognizer.view
            )

        finishInteractiveTransition(
            initialVelocity: animationVelocity
        )
    }
}

extension BottomSheetInteractor {
    /// <note>
    /// `animations` closure gets the current animation progress as the parameter.
    public func animate(
        alongsideTransition animations: @escaping (CGFloat) -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        additionalAnimationsAlongsideTransition = animations
        additionalCompletionAfterTransition = completion
    }
}

extension BottomSheetInteractor {
    public func enableTouchesAlongsideInteractiveTransition() {
        disabledPresentedSubviewsAlongsideTransition.forEachSafe {
            $0.isUserInteractionEnabled = true
        }
        disabledPresentedSubviewsAlongsideTransition.removeAll()
    }

    public func disableTouchesAlongsideInteractiveTransition() {
        guard let presentedViewController = presentedViewController else {
            return
        }

        for subview in presentedViewController.view.subviews where subview.isUserInteractionEnabled {
            subview.isUserInteractionEnabled = false

            disabledPresentedSubviewsAlongsideTransition.append(
                subview
            )
        }
    }
}

extension BottomSheetInteractor {
    public func discardOngoingCancelAnimation() {
        ongoingCancelAnimator?.stopAnimation(
            true
        )
        ongoingCancelAnimator = nil
    }
}

extension BottomSheetInteractor {
    @objc
    private func handleInteractiveGesture(
        _ panGestureRecognizer: UIPanGestureRecognizer
    ) {
        let translationY =
            panGestureRecognizer.translation(
                in: panGestureRecognizer.view
            ).y
        let translationYFromLastInterruption =
            lastInterruptedTranslationY + translationY

        switch panGestureRecognizer.state {
        case .began:
            interactiveGestureDidBegin(
                panGestureRecognizer
            )
        case .changed:
            interactiveGestureDidChange(
                panGestureRecognizer,
                byTranslation: translationYFromLastInterruption
            )
        case .cancelled,
             .failed:
            interactiveGestureDidCancel(
                panGestureRecognizer,
                byTranslation: translationYFromLastInterruption
            )
        case .ended:
            interactiveGestureDidEnd(
                panGestureRecognizer,
                byTranslation: translationYFromLastInterruption
            )
        default: break
        }
    }
}
