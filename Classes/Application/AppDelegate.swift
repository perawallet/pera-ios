// Copyright 2022 Pera Wallet, LDA

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

import CoreData
import Firebase
import FirebaseCrashlytics
import Foundation
import MacaroonUIKit
import MacaroonUtils
import SwiftDate
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate:
    UIResponder,
    UIApplicationDelegate,
    AppLaunchUIHandler ,
    NotificationObserver {
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
    
    var notificationObservations: [NSObjectProtocol] = []
    
    private(set) lazy var appConfiguration = AppConfiguration(
        api: api,
        session: session,
        sharedDataController: sharedDataController,
        walletConnector: walletConnector,
        loadingController: loadingController,
        bannerController: bannerController
    )
    
    private(set) lazy var firebaseAnalytics = FirebaseAnalytics()
    
    private lazy var appLaunchController = createAppLaunchController()

    private lazy var session = Session()
    private lazy var api = ALGAPI(session: session)
    private lazy var sharedDataController = SharedAPIDataController(session: session, api: api)
    private lazy var walletConnector = WalletConnector()
    private lazy var loadingController: LoadingController = BlockingLoadingController(presentingView: window!)
    private lazy var bannerController = BannerController(presentingView: window!)
    
    private lazy var router =
        Router(rootViewController: rootViewController, appConfiguration: appConfiguration)
    
    private lazy var rootViewController = RootViewController(
        target: ALGAppTarget.current,
        appConfiguration: appConfiguration,
        launchController: appLaunchController
    )

    private lazy var pushNotificationController = PushNotificationController(
        target: ALGAppTarget.current,
        session: session,
        api: api,
        bannerController: bannerController
    )
    
    private lazy var networkBannerView = UIView()
    private lazy var containerBlurView = UIVisualEffectView()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        setupAppTarget()
        setupAppLibs()
        
        prepareForLaunch()

        makeWindow()
        makeNetworkBanner()

        launch(with: launchOptions)

        return true
    }
    
    func applicationWillEnterForeground(
        _ application: UIApplication
    ) {
        removeBlurOnWindow()
        
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
        setNeedsNetworkBannerUpdateIfNeeded()
        
        appLaunchController.becomeActive()
    }
    
    func applicationWillResignActive(
        _ application: UIApplication
    ) {
        appLaunchController.resignActive()
    }
    
    func applicationDidEnterBackground(
        _ application: UIApplication
    ) {
        appLaunchController.enterBackground()
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
        guard let scheme = url.scheme else {
            return false
        }
        
        /// <todo>
        /// Schemes should be controlled from a single point.
        switch scheme {
        case "algorand":
            receive(deeplinkWithSource: .url(url))
            return true
        case "algorand-wc":
            receive(deeplinkWithSource: .walletConnectSessionRequest(url))
            return true
        default:
            return false
        }
    }
}

extension AppDelegate {
    func prepareForLaunch() {
        appLaunchController.prepareForLaunch()
    }
    
    func launch(
        with options: [UIApplication.LaunchOptionsKey: Any]?
    ) {
        let src: DeeplinkSource?
        
        if let userInfo = options?[.remoteNotification] as? DeeplinkSource.UserInfo {
            src = .remoteNotification(userInfo, waitForUserConfirmation: false)
        } else if let url = options?[.url] as? URL {
            src = .url(url)
        } else {
            src = nil
        }
        appLaunchController.launch(deeplinkWithSource: src)
    }
    
    func launchOnboarding() {
        appLaunchController.launchOnboarding()
    }
    
    func launchMain(
        completion: (() -> Void)? = nil
    ) {
        appLaunchController.launchMain(completion: completion)
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
    func launchUI(
        _ state: AppLaunchUIState
    ) {
        switch state {
        case .authorization:
            router.launchAuthorization()
        case .onboarding:
            router.launchOnboarding()
        case .main(let completion):
            router.launchMain(completion: completion)
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
        case .walletConnectSessionRequest(let key):
            NotificationCenter.default.post(
                name: WalletConnector.didReceiveSessionRequestNotification,
                object: nil,
                userInfo: [
                    WalletConnector.sessionRequestUserInfoKey: key
                ]
            )
        }
    }
}

extension AppDelegate {
    func receive(
        deeplinkWithSource src: DeeplinkSource
    ) {
        appLaunchController.receive(deeplinkWithSource: src)
    }
}

extension AppDelegate {
    private func setupAppTarget() {
        ALGAppTarget.setup()
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
    private func makeWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
    
    private func makeNetworkBanner() {
        networkBannerView.layer.zPosition = 1
        
        window?.addSubview(networkBannerView)
        networkBannerView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
            
            $0.fitToHeight(0)
        }
        
        observe(notification: NodeSettingsViewController.didChangeNetwork) {
            [unowned self] _ in
            self.setNeedsNetworkBannerUpdateIfNeeded()
        }
    }
    
    private func setNeedsNetworkBannerUpdateIfNeeded() {
        let statusBarManager = window?.windowScene?.statusBarManager
        let height = statusBarManager?.statusBarFrame.height ?? 0
        
        networkBannerView.snp.updateConstraints {
            $0.fitToHeight(height)
        }
        
        switch api.network {
        case .mainnet: networkBannerView.backgroundColor = .clear
        case .testnet: networkBannerView.backgroundColor = AppColors.Shared.Helpers.testnet.uiColor
        }

        rootViewController.setNeedsStatusBarAppearanceUpdate()
    }
}

extension AppDelegate {
    private func setNeedsUserInterfaceStyleUpdateIfNeeded() {
        if session.userInterfaceStyle == .system {
            return
        }

        UserInterfaceStyleController.setNeedsUserInterfaceStyleUpdate(session.userInterfaceStyle)
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
            authChecker: ALGAppAuthChecker(session: session),
            uiHandler: self
        )
    }
}

extension AppDelegate {
    private enum Constants {
        static let sessionInvalidateTime = 60
    }
}
