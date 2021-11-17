// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

open class ModalPresentationController<
    PresentaionConfiguration: ModalPresentationConfiguration
>: UIPresentationController {
    public private(set) lazy var chromeView = UIView()

    public var presentationBounds: CGRect {
        return containerView?.bounds ?? UIScreen.main.bounds
    }

    open override var frameOfPresentedViewInContainerView: CGRect {
        let parentSize = (presentationBounds.size.width, presentationBounds.size.height)
        let size = calculateSizeOfPresentedView(
            inParentWithSize: parentSize
        )
        let origin = calculateOriginOfPresentedView(
            withSize: size,
            inParentWithSize: parentSize
        )

        return CGRect(x: origin.x, y: origin.y, width: size.w, height: size.h)
    }

    public let configuration: PresentaionConfiguration

    public init(
        presentedViewController: UIViewController,
        presentingViewController: UIViewController?,
        configuration: PresentaionConfiguration
    ) {
        self.configuration = configuration

        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
    }

    open func calculateOriginOfPresentedView(
        withSize size: LayoutSize,
        inParentWithSize parentSize: LayoutSize
    ) -> LayoutOffset {
        mc_crash(
            .shouldBeImplementedBySubclass(functionName: #function)
        )
    }

    open func calculateSizeOfPresentedView(
        inParentWithSize parentSize: LayoutSize
    ) -> LayoutSize {
        mc_crash(
            .shouldBeImplementedBySubclass(functionName: #function)
        )
    }

    open override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    open override func presentationTransitionWillBegin() {
        dimBackground()
    }

    open override func dismissalTransitionWillBegin() {
        undimBackground()
    }

    open override func size(
        forChildContentContainer container: UIContentContainer,
        withParentContainerSize parentSize: CGSize
    ) -> CGSize {
        let size = calculateSizeOfPresentedView(
            inParentWithSize: (parentSize.width, parentSize.height)
        )
        return CGSize(width: size.w, height: size.h)
    }
}

extension ModalPresentationController {
    private func dimBackground() {
        guard let containerView = containerView else {
            return
        }

        chromeView.customizeAppearance(
            configuration.chromeStyle
        )
        chromeView.alpha = 0

        containerView.insertSubview(
            chromeView,
            at: 0
        )
        chromeView.snp.makeConstraints {
            $0.setPaddings()
        }

        guard let transitionCoordinator = presentedViewController.transitionCoordinator else {
            chromeView.alpha = 1
            return
        }

        transitionCoordinator.animate(
            alongsideTransition: {
                [unowned self] _ in

                self.chromeView.alpha = 1
            },
            completion: nil
        )
    }

    private func undimBackground() {
        guard let transitionCoordinator = presentedViewController.transitionCoordinator else {
            chromeView.alpha = 0
            return
        }

        if transitionCoordinator.isInteractive {
            return
        }

        transitionCoordinator.animate(
            alongsideTransition: {
                [unowned self] _ in

                self.chromeView.alpha = 0
            },
            completion: nil
        )
    }
}
