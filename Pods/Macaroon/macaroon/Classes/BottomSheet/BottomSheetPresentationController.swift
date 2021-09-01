// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

open class BottomSheetPresentationController:
    ModalPresentationController<BottomSheetPresentationConfiguration>,
    UIGestureRecognizerDelegate {
    public private(set) lazy var overlayView = BottomSheetOverlayView()

    public var presentedContentViewController: UIViewController {
        let navigationController = presentedViewController as? UINavigationController
        return navigationController?.viewControllers.last ?? presentedViewController
    }
    public var presentedScrollView: UIScrollView? {
        return (presentedContentViewController as? BottomSheetPresentable)?.presentedScrollView
    }
    public var modalHeight: ModalHeight {
        return (presentedContentViewController as? ModalCustomPresentable)?.modalHeight ?? .compressed
    }

    public let interactor: BottomSheetInteractor

    public init(
        presentedViewController: UIViewController,
        presentingViewController: UIViewController?,
        interactor: BottomSheetInteractor,
        configuration: BottomSheetPresentationConfiguration = BottomSheetPresentationConfiguration()
    ) {
        self.interactor = interactor

        super.init(
            presentedViewController: presentedViewController,
            presentingViewController: presentingViewController,
            configuration: configuration
        )
    }

    open override func calculateOriginOfPresentedView(
        withSize size: LayoutSize,
        inParentWithSize parentSize: LayoutSize
    ) -> LayoutOffset {
        return (0, parentSize.h - size.h)
    }

    open override func calculateSizeOfPresentedView(
        inParentWithSize parentSize: LayoutSize
    ) -> LayoutSize {
        let targetWidth = parentSize.w
        let targetHeight: LayoutMetric

        switch modalHeight {
        case .compressed,
             .expanded:
            /// <note>
            /// Use `presentedContentViewController` to calculate the height because
            /// navigation controller gives us 0. A preferred height should be set explicitly in order
            /// to add its height into the calculations.
            if let presentedView = presentedContentViewController.view {
                let fittingSize: CGSize

                if modalHeight == .compressed {
                    fittingSize = CGSize((targetWidth, UIView.layoutFittingCompressedSize.height))
                } else {
                    fittingSize = CGSize((targetWidth, UIView.layoutFittingExpandedSize.height))
                }

                targetHeight =
                    presentedView.systemLayoutSizeFitting(
                        fittingSize,
                        withHorizontalFittingPriority: .required,
                        verticalFittingPriority: .defaultLow
                    ).height
            } else {
                targetHeight = parentSize.h
            }
        case .proportional(let proportion):
            targetHeight = parentSize.h * proportion
        case .preferred(let preferredHeight):
            /// <note>
            /// Return a height without the safe area inset.
            targetHeight = preferredHeight + (containerView?.compactSafeAreaInsets.bottom ?? 0)
        }

        let maxHeight = parentSize.h * 0.9

        return (targetWidth, (max(0, min(targetHeight, maxHeight))).ceil())
    }

    open override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        overlayView.frame = calculateFinalFrameOfOverlayView()
    }

    open override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        addOverlay()
        prepareForInteractiveUse()
    }

    open override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        removeOverlay()
    }

    /// <mark>
    /// UIGestureRecognizerDelegate
    open func gestureRecognizerShouldBegin(
        _ gestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return presentedScrollView.unwrap(
            \.isScrollAtTop,
            or: true
        )
    }
}

extension BottomSheetPresentationController {
    private func prepareForInteractiveUse() {
        interactor.animate(
            alongsideTransition: {
                [unowned self] progress in

                self.chromeView.alpha = 1 - progress

                self.updateOverlayLayoutOnDragging(
                    progress: progress
                )
            },
            completion: nil
        )

        presentedView?.addGestureRecognizer(
            interactor.createInteractiveGestureRecognizer()
        )
        overlayView.addGestureRecognizer(
            interactor.createInteractiveGestureRecognizer()
        )

        guard let presentedScrollView = presentedScrollView else {
            return
        }

        let scrollInteractiveGestureRecognizer =
            interactor.createInteractiveScrollingGestureRecognizer()
        scrollInteractiveGestureRecognizer.delegate = self

        presentedScrollView.addGestureRecognizer(
            scrollInteractiveGestureRecognizer
        )
        presentedScrollView.panGestureRecognizer.require(
            toFail: scrollInteractiveGestureRecognizer
        )
    }
}

extension BottomSheetPresentationController {
    private func addOverlay() {
        guard
            let containerView = containerView,
            let presentedView = presentedView
        else {
            return
        }

        containerView.addSubview(
            overlayView
        )
        overlayView.customizeAppearance(
            configuration.overlayStyleSheet
        )
        overlayView.prepareLayout(
            configuration.overlayLayoutSheet
        )

        overlayView.frame =
            CGRect(
                x: 0,
                y: containerView.bounds.height - configuration.overlayOffset,
                width: containerView.bounds.width,
                height: containerView.bounds.height
            )

        let finalFrame = calculateFinalFrameOfOverlayView()

        guard let transitionCoordinator = presentedViewController.transitionCoordinator else {
            overlayView.frame = finalFrame
            return
        }

        transitionCoordinator.animate(
            alongsideTransition: {
                [unowned self] _ in

                self.overlayView.frame = finalFrame
            },
            completion: nil
        )
    }

    private func updateOverlayLayoutOnDragging(
        progress: CGFloat
    ) {
        guard
            let containerView = containerView,
            let presentedView = presentedView
        else {
            return
        }

        let presentedMinY = presentedView.frame.minY

        var draggingFrame = overlayView.frame
        draggingFrame.origin.y = presentedMinY - configuration.overlayOffset
        overlayView.frame = draggingFrame

        if presentedMinY >= containerView.bounds.height {
            overlayView.resetShadowAppearance()
        }
    }

    private func removeOverlay() {
        if interactor.inProgress {
            return
        }

        var finalFrame = overlayView.frame
        finalFrame.origin.y = presentationBounds.height - configuration.overlayOffset

        guard let transitionCoordinator = presentedViewController.transitionCoordinator else {
            overlayView.frame = finalFrame
            return
        }

        transitionCoordinator.animate(
            alongsideTransition: {
                [unowned self] _ in

                self.overlayView.frame = finalFrame
            },
            completion: nil
        )
    }
}

extension BottomSheetPresentationController {
    private func calculateFinalFrameOfOverlayView() -> CGRect {
        guard let containerView = containerView else {
            return overlayView.frame
        }

        let presentedHeight = calculateSizeOfPresentedView(
            inParentWithSize: (containerView.bounds.width, containerView.bounds.height)
        ).h
        var presentedOverlayHeight =
            presentedHeight +
            configuration.overlayOffset

        /// <note>
        /// Expect that `calculateSizeOfPresentedView(inParentWithSize:)` returns
        /// a height with the safe area inset, so it isn't needed to be considered here. For autosizing,
        /// the height will be calculated properly including the safe area inset itself but not at the
        /// moment that the overlay size is calculated.
        if !modalHeight.isExplicit {
            presentedOverlayHeight += containerView.compactSafeAreaInsets.bottom
        }

        var finalFrame = overlayView.frame
        finalFrame.origin.y = containerView.bounds.height - presentedOverlayHeight
        return finalFrame
    }
}
