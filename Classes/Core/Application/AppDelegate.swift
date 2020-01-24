//
//  AppDelegate.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import SwiftDate
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private enum Constants {
        static let sessionInvalidateTime: Double = 300.0
    }
    
    private lazy var session = Session()
    private lazy var api: API = {
        let api = API(session: session)
        api.token = Environment.current.serverToken
        return api
    }()
    private lazy var appConfiguration = AppConfiguration(api: api, session: session)
    private lazy var pushNotificationController = PushNotificationController(api: api)
    
    private var rootViewController: RootViewController?
    
    private(set) lazy var accountManager: AccountManager = AccountManager(api: api)
    
    private var timer: PollingOperation?
    private var shouldInvalidateAccountFetch = false
    
    private var shouldInvalidateUserSession: Bool = false
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        FirebaseApp.configure()
        SwiftDate.setupDateRegion()
        setupWindow()
        
        return true
    }
    
    private func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        rootViewController = RootViewController(appConfiguration: appConfiguration)
        
        guard let rootViewController = rootViewController else {
            return
        }
        
        window?.backgroundColor = .white
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        window?.rootViewController = NavigationController(rootViewController: rootViewController)
        window?.makeKeyAndVisible()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let pushToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        pushNotificationController.authorizeDevice(with: pushToken)
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard let userInfo = userInfo as? [String: Any],
            let userInfoDictionary = userInfo["aps"] as? [String: Any],
            let remoteNotificationData = try? JSONSerialization.data(withJSONObject: userInfoDictionary, options: .prettyPrinted),
            let algorandNotification = try? JSONDecoder().decode(AlgorandNotification.self, from: remoteNotificationData) else {
                return
        }
        
        guard let accountId = parseAccountId(from: algorandNotification) else {
            if let message = algorandNotification.alert {
                pushNotificationController.showNotificationMessage(message)
            }
            return
        }
        
        handleNotificationActions(for: accountId, with: algorandNotification.details)
    }
    
    private func parseAccountId(from algorandNotification: AlgorandNotification) -> String? {
        guard let notificationDetails = algorandNotification.details,
            let notificationType = notificationDetails.notificationType else {
                return nil
        }
        
        switch notificationType {
        case .transactionReceived,
             .assetTransactionReceived:
            return notificationDetails.receiverAddress
        case .transactionSent,
             .assetTransactionSent:
            return notificationDetails.senderAddress
        case .assetSupportRequest:
            return notificationDetails.receiverAddress
        case .assetSupportSuccess:
            return notificationDetails.receiverAddress
        default:
            return nil
        }
    }
    
    private func handleNotificationActions(for accountId: String, with notificationDetail: NotificationDetail?) {
        if UIApplication.shared.applicationState == .active,
            let notificationDetail = notificationDetail {
            
            if let notificationtype = notificationDetail.notificationType {
                if notificationtype == .assetSupportRequest {
                    rootViewController?.openAsset(from: notificationDetail, for: accountId)
                    return
                }
            }
            
            pushNotificationController.show(with: notificationDetail) {
                self.rootViewController?.openAsset(from: notificationDetail, for: accountId)
            }
        } else {
            guard let notificationDetail = notificationDetail else {
                return
            }
            rootViewController?.openAsset(from: notificationDetail, for: accountId)
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        timer?.invalidate()
        
        guard let rootViewController = rootViewController else {
            return
        }
        
        NotificationCenter.default.post(
            name: Notification.Name.ApplicationWillEnterForeground,
            object: self,
            userInfo: nil
        )
        
        if shouldInvalidateUserSession {
            shouldInvalidateUserSession = false
            appConfiguration.session.isValid = false
            
            guard let topNavigationViewController = window?.rootViewController?.presentedViewController as? NavigationController,
                let topViewController = topNavigationViewController.viewControllers.last else {
                    return
            }
            
            rootViewController.route(
                to: .choosePassword(mode: .login, route: nil),
                from: topViewController,
                by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
            )
            return
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        timer = PollingOperation(interval: Constants.sessionInvalidateTime) { [weak self] in
            self?.shouldInvalidateUserSession = true
        }
        
        timer?.start()
        
        self.invalidateAccountManagerFetchPolling()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let parser = DeepLinkParser(url: url)
        
        guard let screen = parser.expectedScreen,
            let rootViewController = rootViewController else {
                return false
        }
        
        return rootViewController.handleDeepLinkRouting(for: screen)
    }
    
    // MARK: Core Data stack
    
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
    
    // MARK: Core Data Saving support
    
    func saveContext () {
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
    
    private func fetchAccounts(round: Int64? = nil) {
        guard !shouldInvalidateAccountFetch else {
            return
        }
        
        if let user = session.authenticatedUser {
            accountManager.user = user
            
            self.accountManager.waitForNextRoundAndFetchAccounts(round: round) { nextRound in
                self.fetchAccounts(round: nextRound)
            }
        }
    }

    func validateAccountManagerFetchPolling() {
        shouldInvalidateAccountFetch = false
        
        fetchAccounts()
    }
    
    func invalidateAccountManagerFetchPolling() {
        shouldInvalidateAccountFetch = true
    }
}
