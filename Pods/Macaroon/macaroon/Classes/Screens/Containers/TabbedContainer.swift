// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol TabbedContainer: Container {
    var selectedScreen: UIViewController? { get set }
    var screens: [UIViewController] { get }
}

extension UITabBarController: TabbedContainer {
    public var selectedScreen: UIViewController? {
        get { return selectedViewController }
        set { selectedViewController = newValue }
    }

    public var screens: [UIViewController] {
        return viewControllers ?? []
    }
}
