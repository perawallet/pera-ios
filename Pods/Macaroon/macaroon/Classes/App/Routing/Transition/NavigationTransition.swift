// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

protocol NavigationTransition: Transition {
    var source: UIViewController? { get set }
}

extension NavigationTransition {
    func prepareForTransition(
        from source: UIViewController,
        to destination: [UIViewController]
    ) {
        guard
            let source = source as? StatusBarConfigurable,
            let lastDestination = destination.last as? StatusBarConfigurable
        else {
            return
        }

        let isStatusBarHidden = source.statusBarHidden

        lastDestination.hidesStatusBarOnAppeared = isStatusBarHidden
        lastDestination.statusBarHidden = isStatusBarHidden
    }
}

struct PushTransition: NavigationTransition {
    var source: UIViewController?
    var destination: [UIViewController]
    var completion: Completion?

    func perform(
        animated: Bool
    ) {
        if destination.isEmpty {
            completion?()
            return
        }

        guard
            let source = source,
            let navigationContainer =
                source as? UINavigationController ?? source.navigationController
        else {
            completion?()
            return
        }

        prepareForTransition(
            from: source,
            to: destination
        )

        if destination.count == 1 {
            let nextScreen = destination[0]

            navigationContainer.pushViewController(
                nextScreen,
                animated: animated,
                completion: completion
            )
        } else {
            let nextScreens = navigationContainer.viewControllers + destination

            navigationContainer.setViewControllers(
                nextScreens,
                animated: animated,
                completion: completion
            )
        }
    }
}

struct StackTransition: NavigationTransition {
    var source: UIViewController?
    var destination: [UIViewController]
    /// <note>
    /// newStack == ...sourceLink + destination
    var overridesFullStack: Bool
    var completion: Completion?

    func perform(
        animated: Bool
    ) {
        guard
            let source = source,
            let navigationContainer =
                source as? UINavigationController ?? source.navigationController
        else {
            completion?()
            return
        }

        prepareForTransition(
            from: source,
            to: destination
        )

        let currentStack = navigationContainer.viewControllers

        if !overridesFullStack,
           let sourceIndex =
                currentStack.firstIndex(
                    of: source
                ) {
            let newStack = Array(currentStack[0...sourceIndex]) + destination

            navigationContainer.setViewControllers(
                newStack,
                animated: true,
                completion: completion
            )

            return
        }

        navigationContainer.setViewControllers(
            destination,
            animated: !currentStack.isEmpty,
            completion: completion
        )

    }
}

extension UINavigationController {
    public func setViewControllers(
        _ viewControllers: [UIViewController],
        animated: Bool,
        completion: (() -> Void)?
    ) {
        setViewControllers(
            viewControllers,
            animated: animated
        )
        finishTransition(
            completion,
            animated: animated
        )
    }

    public func pushViewController(
        _ screen: UIViewController,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        pushViewController(
            screen,
            animated: animated
        )
        finishTransition(
            completion,
            animated: animated
        )
    }

    public func popViewController(
        animated: Bool,
        completion: (() -> Void)?
    ) -> UIViewController? {
        let poppedScreen =
            popViewController(
                animated: animated
            )
        finishTransition(
            completion,
            animated: animated
        )
        return poppedScreen
    }

    public func popToViewController(
        _ viewController: UIViewController,
        animated: Bool,
        completion: (() -> Void)?
    ) -> [UIViewController]? {
        let poppedScreens =
            popToViewController(
                viewController,
                animated: animated
            )
        finishTransition(
            completion,
            animated: animated
        )
        return poppedScreens
    }
}

extension UINavigationController {
    private func finishTransition(
        _ completion: (() -> Void)?,
        animated: Bool
    ) {
        guard let transitionCoordinator = transitionCoordinator else {
            completion?()
            return
        }

        if !animated {
            completion?()
            return
        }

        transitionCoordinator.animate(
            alongsideTransition: nil
        ) { _ in
            completion?()
        }
    }
}
