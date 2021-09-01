// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol NavigationBarConfigurable: UIViewController {
    var navigationBarHidden: Bool { get set }

    /// <note>
    /// `Pop` or `Dismiss` left bar button will be inserted automatically when
    /// `setNeedsNavigationBarAppearanceUpdate()` is called.
    var leftNavigationBarButtonItems: [NavigationBarButtonItem] { get set }

    var rightNavigationBarButtonItems: [NavigationBarButtonItem] { get set }

    /// <note>
    /// Return `true` if `Pop` or `Dismiss` left bar button should be hidden.
    var hidesCloseBarButton: Bool { get set }
    var hidesDismissBarButtonIniOS13AndLater: Bool { get set }

    var disablesInteractivePop: Bool { get set }

    func makePopNavigationBarButtonItem() -> NavigationBarButtonItem
    func makeDismissNavigationBarButtonItem() -> NavigationBarButtonItem
}

extension NavigationBarConfigurable {
    public func setNeedsNavigationBarAppearanceUpdate() {
        setNeedsNavigationBarLeftBarButtonsUpdate()
        setNeedsNavigationBarRightBarButtonsUpdate()
    }

    public func setNeedsNavigationBarLeftBarButtonsUpdate() {
        func insertPopBarButtonItem() {
            leftNavigationBarButtonItems.insert(
                makePopNavigationBarButtonItem(),
                at: 0
            )
        }

        func insertDismissBarButtonItem() {
            leftNavigationBarButtonItems.insert(
                makeDismissNavigationBarButtonItem(),
                at: 0
            )
        }

        guard let navigationController = navigationController,
              navigationController == parent
        else {
            return
        }

        if hidesCloseBarButton {
            navigationItem.hidesBackButton = true
        } else {
            navigationItem.hidesBackButton = false

            if navigationController.viewControllers.first == self {
                if presentingViewController != nil {
                    if #available(iOS 13, *) {
                        if !hidesDismissBarButtonIniOS13AndLater {
                            insertDismissBarButtonItem()
                        }
                    } else {
                        insertDismissBarButtonItem()
                    }
                }
            } else {
                insertPopBarButtonItem()
            }
        }

        navigationItem.leftBarButtonItems =
            leftNavigationBarButtonItems.map {
                $0.asSystemBarButtonItem()
            }

        if isViewLoaded {
            navigationController.navigationBar.layoutIfNeeded()
        }
    }

    public func setNeedsNavigationBarRightBarButtonsUpdate() {
        navigationItem.rightBarButtonItems =
            rightNavigationBarButtonItems.map {
                $0.asSystemBarButtonItem()
            }

        if isViewLoaded {
            navigationController?.navigationBar.layoutIfNeeded()
        }
    }

    public func setNeedsNavigationBarAppearanceUpdateOnBeingAppeared() {
        guard let navigationController = navigationController else {
            return
        }

        if navigationController.isNavigationBarHidden == navigationBarHidden {
            return
        }

        navigationController.setNavigationBarHidden(
            navigationBarHidden,
            animated:
                !(
                    navigationController.isBeingPresented &&
                    navigationController.viewControllers.first == self
                )
        )
    }
}
