// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

protocol PresentationTransition: Transition {
    var source: UIViewController? { get set }
    var navigationContainer: UINavigationController? { get set }
}

extension PresentationTransition {
    func prepareForTransition(
        from source: UIViewController,
        to destination: [UIViewController],
        in navigationContainer: UINavigationController?
    ) -> UIViewController {
        if
            let lastDestination = destination.last as? StatusBarConfigurable,
            let source = source as? StatusBarConfigurable,
            source.statusBarHidden {
            lastDestination.hidesStatusBarOnPresented = true
            lastDestination.statusBarHidden = true
        }

        guard let navigationContainer = navigationContainer else {
            return destination[0]
        }

        navigationContainer.setViewControllers(
            destination,
            animated: false
        )
        return navigationContainer
    }

    func finishTransition(
        fullScreen: Bool,
        from source: UIViewController,
        to destination: UIViewController
    ) {
        if fullScreen {
            return
        }

        destination.presentationController?.delegate =
            source as? UIAdaptivePresentationControllerDelegate
    }
}

struct ModalTransition: PresentationTransition {
    var source: UIViewController?
    var destination: [UIViewController]
    var navigationContainer: UINavigationController?
    var completion: Completion?

    func perform(
        animated: Bool
    ) {
        if destination.isEmpty {
            completion?()
            return
        }

        guard let source = source else {
            completion?()
            return
        }

        let presentedScreen =
            prepareForTransition(
                from: source,
                to: destination,
                in: navigationContainer
            )

        source.present(
            presentedScreen,
            animated: animated) {
            finishTransition(
                fullScreen: false,
                from: source,
                to: presentedScreen
            )

            completion?()
        }
    }
}

struct BuiltInModalTransition: PresentationTransition {
    var source: UIViewController?
    var destination: [UIViewController]
    var navigationContainer: UINavigationController?
    var modalPresentationStyle: UIModalPresentationStyle
    var modalTransitionStyle: UIModalTransitionStyle?
    var completion: Completion?

    func perform(
        animated: Bool
    ) {
        if destination.isEmpty {
            completion?()
            return
        }

        guard let source = source else {
            completion?()
            return
        }

        let presentedScreen =
            prepareForTransition(
                from: source,
                to: destination,
                in: navigationContainer
            )
        presentedScreen.modalPresentationStyle = modalPresentationStyle

        if let modalTransitionStyle = modalTransitionStyle {
            presentedScreen.modalTransitionStyle = modalTransitionStyle
        }

        source.present(
            presentedScreen,
            animated: animated) {
            finishTransition(
                fullScreen: modalPresentationStyle == .fullScreen,
                from: source,
                to: presentedScreen
            )

            completion?()
        }
    }
}

struct CustomModalTransition: PresentationTransition {
    var source: UIViewController?
    var destination: [UIViewController]
    var navigationContainer: UINavigationController?
    unowned var transitioningDelegate: UIViewControllerTransitioningDelegate
    var completion: Completion?

    func perform(
        animated: Bool
    ) {
        if destination.isEmpty {
            completion?()
            return
        }

        guard let source = source else {
            completion?()
            return
        }

        let presentedScreen =
            prepareForTransition(
                from: source,
                to: destination,
                in: navigationContainer
            )
        presentedScreen.modalPresentationStyle = .custom
        presentedScreen.modalPresentationCapturesStatusBarAppearance = true
        presentedScreen.transitioningDelegate = transitioningDelegate

        source.present(
            presentedScreen,
            animated: animated) {
            finishTransition(
                fullScreen: false,
                from: source,
                to: presentedScreen
            )

            completion?()
        }
    }
}
