//
//  AppDelegate.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private enum Constants {
        static let sessionInvalidateTime: Double = 300.0
    }
    
    private lazy var session = Session()
    private lazy var api = API(base: Environment.current.serverApi, session: session)
    private lazy var appConfiguration = AppConfiguration(api: api, session: session)
    
    private var rootViewController: RootViewController?
    
    private var timer: PollingOperation?
    private var shouldInvalidateUserSession: Bool = false
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
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
        
        if shouldInvalidateUserSession {
            shouldInvalidateUserSession = false
            session.isExpired = true
            
            guard let topNavigationViewController = window?.rootViewController?.presentedViewController as? NavigationController,
                let topViewController = topNavigationViewController.viewControllers.last else {
                    return
            }
            
            rootViewController.route(to: .choosePassword(mode: .login), from: topViewController, by: .present)
            return
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        timer = PollingOperation(interval: Constants.sessionInvalidateTime) { [weak self] in
            self?.shouldInvalidateUserSession = true
        }
        
        timer?.start()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
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

}
