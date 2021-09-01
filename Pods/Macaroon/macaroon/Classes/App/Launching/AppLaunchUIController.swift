// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

public protocol AppLaunchUIController: AppLaunchController {
    associatedtype SomeAppLaunchUIHandler: AppLaunchUIHandler

    var uiHandler: SomeAppLaunchUIHandler { get }
}

/// <mark>
/// Auth
public protocol AppAuthLaunchUIController: AppAuthLaunchController, AppLaunchUIController
where SomeAppLaunchUIHandler: AppAuthLaunchUIHandler { }
