// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

/// <src>
/// https://danielgauthier.me/2020/02/24/vctransitions1.html

open class BottomSheetTransitionController:
    NSObject,
    UIViewControllerTransitioningDelegate {
    public var presentationConfiguration: BottomSheetPresentationConfiguration

    public let interactor: BottomSheetInteractor

    public init(
        presentingViewController: UIViewController,
        presentationConfiguration: BottomSheetPresentationConfiguration =
            BottomSheetPresentationConfiguration(),
        completion: (() -> Void)? = nil
    ) {
        self.presentationConfiguration = presentationConfiguration
        self.interactor = BottomSheetInteractor(
            presentingViewController: presentingViewController,
            completion: completion
        )

        super.init()
    }

    /// <mark>
    /// UIViewControllerTransitioningDelegate
    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        return BottomSheetPresentationController(
            presentedViewController: presented,
            presentingViewController: presenting,
            interactor: interactor,
            configuration: presentationConfiguration
        )
    }

    open func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return BottomSheetAnimator(isPresenting: true)
    }

    open func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return BottomSheetAnimator(isPresenting: false)
    }

    public func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        return interactor.inProgress ? interactor : nil
    }
}
