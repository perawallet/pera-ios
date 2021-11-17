// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

open class BottomSheetAnimator: ModalAnimator {
    open override func calculatePresentedInitalFrameOnPresenting(
        using transitionContext: UIViewControllerContextTransitioning
    ) -> CGRect {
        let containerBounds = transitionContext.containerView.bounds

        guard let presentedFinalFrame = transitionContext.destinationFinalFrame else {
            return containerBounds
        }

        return CGRect(
            origin: CGPoint(x: presentedFinalFrame.minX, y: containerBounds.height),
            size: presentedFinalFrame.size
        )
    }

    open override func calculatePresentedFinalFrameOnDismissing(
        using transitionContext: UIViewControllerContextTransitioning
    ) -> CGRect {
        let containerBounds = transitionContext.containerView.bounds

        guard let presentedFinalFrame = transitionContext.sourceFinalFrame else {
            return containerBounds
        }

        return CGRect(
            origin: CGPoint(x: presentedFinalFrame.minX, y: containerBounds.height),
            size: presentedFinalFrame.size
        )
    }
}
