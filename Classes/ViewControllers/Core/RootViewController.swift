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
    
    private(set) lazy var tabBarViewController = TabBarController(configuration: appConfiguration.all())
    
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
        
        if appConfiguration.session.isExpired {
            if appConfiguration.session.hasPassword() &&
                appConfiguration.session.authenticatedUser != nil {
                open(.choosePassword(mode: .login), by: .present)
            } else {
                open(.introduction(mode: .initialize), by: .launch, animated: false)
            }
        } else {
            open(.home, by: .push, animated: false)
        }
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
        open(.home, by: .present, animated: false)
    }
}
