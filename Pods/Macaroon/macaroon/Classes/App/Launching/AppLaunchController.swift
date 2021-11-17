// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

public protocol AppLaunchController: AnyObject {
    func launch()
    func enterForeground()
    func becomeActive()
    func resignActive()
    func enterBackground()
}

extension AppLaunchController {
    public func enterForeground() { }
    public func becomeActive() { }
    public func resignActive() { }
    public func enterBackground() { }
}

/// <mark>
/// Auth
public protocol AppAuthLaunchController: AppLaunchController {
    typealias AuthCompletionHandler = (Swift.Error?) -> Void

    func launchAfterSignIn(onCompleted execute: AuthCompletionHandler?)
    func launchAfterSignUp(onCompleted execute: AuthCompletionHandler?)
    func launchAfterSignOut(onCompleted execute: AuthCompletionHandler?)
}
