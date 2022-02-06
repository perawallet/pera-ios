// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  AppDelegate.swift

import Foundation
import UIKit
import CoreData
import Firebase
import SwiftDate
import UserNotifications
import FirebaseCrashlytics

@UIApplicationMain
class AppDelegate:
    UIResponder,
    UIApplicationDelegate,
    AppLaunchUIHandler {
    static var shared: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "algorand")
        container.loadPersistentStores { storeDescription, error in
            if var url = storeDescription.url {
                var resourceValues = URLResourceValues()
                resourceValues.isExcludedFromBackup = true
                
                do {
                    try url.setResourceValues(resourceValues)
                } catch {
                }
            }
            
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()

    var window: UIWindow?
    
    private lazy var appLaunchController = createAppLaunchController()

    private lazy var session = Session()
    private lazy var api = ALGAPI(session: session)
    private lazy var sharedDataController = SharedAPIDataController(session: session, api: api)
    private lazy var walletConnector = WalletConnector()
    private lazy var loadingController: LoadingController = BlockingLoadingController(presentingView: window!)
    private lazy var bannerController = BannerController(window: window!)

    private(set) lazy var appConfiguration = AppConfiguration(
        api: api,
        session: session,
        sharedDataController: sharedDataController,
        walletConnector: walletConnector,
        loadingController: loadingController,
        bannerController: bannerController
    )
    
    private lazy var router =
        Router(rootViewController: rootViewController, appConfiguration: appConfiguration)
    private lazy var deepLinkRouter =
        DeepLinkRouter(router: router, appConfiguration: appConfiguration)
    
    private lazy var rootViewController = RootViewController(appConfiguration: appConfiguration)

    private lazy var pushNotificationController =
        PushNotificationController(session: session, api: api, bannerController: bannerController)

    private(set) lazy var firebaseAnalytics = FirebaseAnalytics()

    private(set) var incomingWCSessionRequest: String?
    
    private lazy var containerBlurView = UIVisualEffectView()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        setupWindow()
        setupAppLibs()

        launch(with: launchOptions)

        return true
    }
    
    func applicationWillEnterForeground(
        _ application: UIApplication
    ) {
        NotificationCenter.default.post(
            name: .ApplicationWillEnterForeground,
            object: self,
            userInfo: nil
        )
    }
    
    func applicationDidBecomeActive(
        _ application: UIApplication
    ) {
        setNeedsUserInterfaceStyleUpdateIfNeeded()
        removeBlurOnWindow()
        
        appLaunchController.becomeActive()
    }
    
    func applicationWillResignActive(
        _ application: UIApplication
    ) {
        appLaunchController.resignActive()

        showBlurOnWindow()
    }

    func applicationWillTerminate(
        _ application: UIApplication
    ) {
        saveContext()
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        authorizeNotifications(for: deviceToken)
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        NotificationCenter.default.post(
            name: .NotificationDidReceived,
            object: self,
            userInfo: nil
        )
        
        appLaunchController.receive(
            deeplinkWithSource: .remoteNotification(
                userInfo,
                waitForUserConfirmation: UIApplication.shared.isActive
            )
        )
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        return shouldHandleDeepLinkRouting(from: url)
    }
}

extension AppDelegate {
    func launchUI(
        _ state: AppLaunchUIState
    ) {
        switch state {
        case .authorization:
            router.launchAuthorization()
        case .onboarding:
            router.launchOnboarding()
        case .main:
            router.launchMain()
        case .mainAfterAuthorization(let presentedViewController, let completion):
            router.launcMainAfterAuthorization(
                presented: presentedViewController,
                completion: completion
            )
        case .remoteNotification(let notification, let screen):
            guard let someScreen = screen else {
                pushNotificationController.present(notification: notification)
                return
            }
            
            pushNotificationController.present(notification: notification) {
                [unowned self] in
                self.router.launch(deeplink: someScreen)
            }
        case .deeplink(let screen):
            router.launch(deeplink: screen)
        }
    }
}

extension AppDelegate {
    private func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
    
    private func setupAppLibs() {
        /// <mark>
        /// Firebase
        firebaseAnalytics.initialize()
        
        /// <mark>
        /// SwiftDate
        SwiftDate.defaultRegion = Region(
            calendar: Calendar.autoupdatingCurrent,
            zone: TimeZone.autoupdatingCurrent,
            locale: Locales.autoUpdating
        )
    }
}

extension AppDelegate {
    private func setNeedsUserInterfaceStyleUpdateIfNeeded() {
        /// <note>
        /// `traitCollectionDidChange` is not called when the user interface style is changed from
        /// the device settings while the app is launched. It takes a minor delay to receive correct
        /// system interface value from `traitCollection`.
        if session.userInterfaceStyle != .system {
            return
        }
        
        asyncMain(afterDuration: 1) {
            UserInterfaceStyleController.setNeedsUserInterfaceStyleUpdate(.system)
        }
    }
}

extension AppDelegate {
    func launch(
        with options: [UIApplication.LaunchOptionsKey: Any]?
    ) {
        let src: DeeplinkSource?
        
        if let userInfo = options?[.remoteNotification] as? DeeplinkSource.UserInfo {
            src = .remoteNotification(userInfo, waitForUserConfirmation: false)
        } else {
            src = nil
        }
        appLaunchController.launch(deeplinkWithSource: src)
    }
    
    func launchOnboarding() {
        appLaunchController.launchOnboarding()
    }
    
    func launchMain() {
        appLaunchController.launchMain()
    }
    
    func launchMainAfterAuthorization(
        presented viewController: UIViewController
    ) {
        appLaunchController.launchMainAfterAuthorization(presented: viewController)
    }
    
    @discardableResult
    func route<T: UIViewController>(
        to screen: Screen,
        from viewController: UIViewController,
        by style: Screen.Transition.Open,
        animated: Bool = true,
        then completion: EmptyHandler? = nil
    ) -> T? {
        return router.route(
            to: screen,
            from: viewController,
            by: style,
            animated: animated,
            then: completion
        )
    }
    
    func findVisibleScreen() -> UIViewController {
        return router.findVisibleScreen()
    }
}

extension AppDelegate {
    private func showBlurOnWindow() {
        containerBlurView.effect = nil
        UIView.animate(withDuration: 3.0) {
            self.containerBlurView = VisualEffectViewWithCustomIntensity(effect: UIBlurEffect(style: .light), intensity: 0.25)
        }
        containerBlurView.frame = UIScreen.main.bounds
        window?.addSubview(containerBlurView)
    }
    
    private func removeBlurOnWindow() {
        containerBlurView.removeFromSuperview()
    }
}

extension AppDelegate {
    private func authorizeNotifications(for deviceToken: Data) {
        let pushToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        pushNotificationController.authorizeDevice(with: pushToken)
    }

    private func shouldHandleDeepLinkRouting(from url: URL) -> Bool {
//        let parser = DeepLinkParser(url: url)
//
//        if let sessionRequest = parser.wcSessionRequestText {
//            if let user = appConfiguration.session.authenticatedUser,
//               !user.accounts.isEmpty {
//                incomingWCSessionRequest = sessionRequest
//                return true
//            }
//
//            return false
//        }
//
//        guard let screen = parser.expectedScreen else {
//                return false
//        }
//
//        return deepLinkRouter.handleDeepLinkRouting(for: screen)
        return true
    }

    func resetWCSessionRequest() {
        incomingWCSessionRequest = nil
    }
}

extension AppDelegate {
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension AppDelegate {
    private func createAppLaunchController() -> AppLaunchController {
        return ALGAppLaunchController(
            session: session,
            api: api,
            sharedDataController: sharedDataController,
            uiHandler: self
        )
    }
}

extension AppDelegate {
    private enum Constants {
        static let sessionInvalidateTime = 60
    }
}
