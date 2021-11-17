// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

open class NavigationContainer:
    UINavigationController,
    ScreenComposable,
    UINavigationControllerDelegate,
    UIGestureRecognizerDelegate {
    public var isPushAnimationInProgress = false

    open override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return topViewController?.preferredStatusBarUpdateAnimation ?? .none
    }

    deinit {
        delegate = nil
        interactivePopGestureRecognizer?.delegate = nil
    }

    open func customizeAppearance() {
        customizeNavigationBarAppearance()
        customizeViewAppearance()
    }

    open func customizeNavigationBarAppearance() {}
    open func customizeViewAppearance() {}
    open func prepareLayout() {}

    open func setListeners() {
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }

    open func linkInteractors() {}

    open override func viewDidLoad() {
        super.viewDidLoad()
        compose()
    }

    open override func pushViewController(
        _ viewController: UIViewController,
        animated: Bool
    ) {
        isPushAnimationInProgress = true

        super.pushViewController(
            viewController,
            animated: animated
        )
    }

    /// <mark>
    /// UINavigationControllerDelegate
    open func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        guard let navigationContainer = navigationController as? NavigationContainer else {
            return
        }

        navigationContainer.isPushAnimationInProgress = false
    }

    /// <mark>
    /// UIGestureRecognizerDelegate
    open func gestureRecognizerShouldBegin(
        _ gestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if gestureRecognizer != interactivePopGestureRecognizer {
            return true
        }

        if let visibleViewController = visibleViewController as? NavigationBarConfigurable,
           visibleViewController.disablesInteractivePop {
            return false
        }

        return
            viewControllers.count > 1 &&
            !isPushAnimationInProgress
    }
}
