//
//  ViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    // MARK: Properties

    let appConfiguration: AppConfiguration
    
    private var router: Router?
    
    private(set) lazy var tabBarViewController = TabBarController(route: nil, configuration: appConfiguration.all())
    
    // MARK: Initialization
    
    init(appConfiguration: AppConfiguration) {
        self.appConfiguration = appConfiguration
        
        super.init(nibName: nil, bundle: nil)
        
        self.router = Router(rootViewController: self)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = SharedColors.warmWhite
        
        if !appConfiguration.session.isValid {
            if appConfiguration.session.hasPassword() &&
                appConfiguration.session.authenticatedUser != nil {
                open(.choosePassword(mode: .login, route: nil), by: .present)
            } else {
                open(.introduction(mode: .initialize), by: .launch, animated: false)
            }
        } else {
            open(.home(route: nil), by: .launch, animated: false)
            
            DispatchQueue.main.async {
                UIApplication.shared.appDelegate?.validateAccountManagerFetchPolling()
            }
        }
    }
    
    func handleDeepLinkRouting(for screen: Screen) -> Bool {
        var shouldHandleDeepLinking = false
        
        if !appConfiguration.session.isValid {
            if appConfiguration.session.hasPassword() && appConfiguration.session.authenticatedUser != nil {
                shouldHandleDeepLinking = open(.choosePassword(mode: .login, route: screen), by: .present) != nil
            } else {
                shouldHandleDeepLinking = open(.introduction(mode: .initialize), by: .launch, animated: false) != nil
            }
        } else {
            guard let topViewController = UIApplication.topViewController() else {
                return false
            }
            
            shouldHandleDeepLinking = topViewController.open(screen, by: .push, animated: true) != nil
            
            DispatchQueue.main.async {
                UIApplication.shared.appDelegate?.validateAccountManagerFetchPolling()
            }
        }
        
        return shouldHandleDeepLinking
    }

    @discardableResult
    func route<T: UIViewController>(
        to screen: Screen,
        from viewController: UIViewController,
        by style: Screen.Transition.Open,
        animated: Bool = true,
        then completion: ScreenTransitionCompletion? = nil
    ) -> T? {
        
        return router?.route(to: screen, from: viewController, by: style, animated: animated, then: completion)
    }
    
    func launch() {
        open(.home(route: nil), by: .present, animated: false)
        
        DispatchQueue.main.async {
            UIApplication.shared.appDelegate?.validateAccountManagerFetchPolling()
        }
    }
}
