// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol StatusBarConfigurable: UIViewController {
    /// <note>
    /// False for most cases. Don't set it directly, instead set `hidesStatusBarOnAppeared` and
    /// `hidesStatusBarOnPresented` respectively.
    ///
    /// <sample>
    /// If a screen is pushed while the status bar is hidden, this variable should be true for
    /// the screen to prevent an unneeded status bar animation.
    var statusBarHidden: Bool { get set }

    var hidesStatusBarOnAppeared: Bool { get set }

    /// <note>
    /// If the screen is being presented, then the value will be counted primarily.
    var hidesStatusBarOnPresented: Bool { get set }
}

extension StatusBarConfigurable {
    /// <note>
    /// Called in `viewWillAppear(:)`
    public func setNeedsStatusBarAppearanceUpdateOnBeingAppeared() {
        if hidesStatusBarOnPresented,
           presentingViewController != nil {
            if statusBarHidden {
                return
            }

            statusBarHidden = true
        } else {
            if statusBarHidden == hidesStatusBarOnAppeared {
                return
            }

            statusBarHidden = hidesStatusBarOnAppeared
        }

        let animator = UIViewPropertyAnimator(duration: 0.25, curve: .linear) {
            [unowned self] in

            self.setNeedsStatusBarAppearanceUpdate()
        }
        animator.startAnimation()
    }

    /// <note>
    /// Called in `viewWillDisappear(:)`
    public func setNeedsStatusBarAppearanceUpdateOnBeingDisappeared() {
        guard var presentedScreen = presentedViewController else {
            return
        }

        if let presentedNavigationContainer = presentedScreen as? UINavigationController,
           let presentedNavigationScreen = presentedNavigationContainer.viewControllers.last {
            presentedScreen = presentedNavigationScreen
        }

        guard let configurablePresentedScreen = presentedScreen as? StatusBarConfigurable else {
            return
        }

        if configurablePresentedScreen.hidesStatusBarOnPresented ||
           configurablePresentedScreen.hidesStatusBarOnAppeared {
            statusBarHidden = true
        }
    }
}
