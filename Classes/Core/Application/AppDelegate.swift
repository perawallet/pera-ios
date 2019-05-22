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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private enum Constants {
        static let sessionInvalidateTime: Double = 300.0
    }
    
    private lazy var session = Session()
    private lazy var api: API = {
        let api = API(base: Environment.current.serverApi, session: session)
        api.token = Environment.current.serverToken
        return api
    }()
    private lazy var appConfiguration = AppConfiguration(api: api, session: session)
    
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
        
        window?.rootViewController = NavigationController(rootViewController: rootViewController)
        window?.makeKeyAndVisible()
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
            
            rootViewController.route(to: .choosePassword(mode: .login, route: nil), from: topViewController, by: .present)
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
        container.loadPersistentStores { _, error in
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
                print("request: \(nextRound)")
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
