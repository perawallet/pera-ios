// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol ScreenConfigurable: AnyObject {
    var screen: Screen? { get set }

    func viewCustomizeAppearance()
    func viewDidLoad()
    func viewDidLayoutSubviews()
    func viewWillAppear()
    func viewDidAppear()
    func viewWillDisappear()
    func viewDidDisappear()
    func viewDidAttemptInteractiveDismiss()
    func viewDidAppearAfterInteractiveDismiss()
    func viewDidChangePreferredUserInterfaceStyle()
    func viewDidChangePreferredContentSizeCategory()

    /// <warning>
    /// These methods are called if the screen has already being observed the related notifications.
    func viewWillEnterForeground()
    func viewDidEnterBackground()

    func makePopNavigationBarButtonItem() -> NavigationBarButtonItem
    func makeDismissNavigationBarButtonItem() -> NavigationBarButtonItem
}

extension ScreenConfigurable {
    public func viewCustomizeAppearance() {}
    public func viewDidLoad() {}
    public func viewDidLayoutSubviews() {}
    public func viewWillAppear() {}
    public func viewDidAppear() {}
    public func viewWillDisappear() {}
    public func viewDidDisappear() {}
    public func viewDidAttemptInteractiveDismiss() {}
    public func viewDidAppearAfterInteractiveDismiss() {}
    public func viewDidChangePreferredUserInterfaceStyle() {}
    public func viewDidChangePreferredContentSizeCategory() {}

    public func viewWillEnterForeground() {}
    public func viewDidEnterBackground() {}

    public func makePopNavigationBarButtonItem() -> NavigationBarButtonItem {
        mc_crash(
            .popNavigationBarButtonItemNotFound
        )
    }

    public func makeDismissNavigationBarButtonItem() -> NavigationBarButtonItem {
        mc_crash(
            .dismissNavigationBarButtonItemNotFound
        )
    }
}
