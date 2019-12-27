//
//  ViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
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
        
        open(.splash, by: .launch, animated: false)
    }
    
    func setupTabBarController(withInitial screen: Screen? = nil) {
        if tabBarViewController.parent != nil {
            return
        }
        
        addChild(tabBarViewController)
        view.addSubview(tabBarViewController.view)
        
        tabBarViewController.view.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
        tabBarViewController.route = screen
        
        tabBarViewController.didMove(toParent: self)
    }
    
    func handleDeepLinkRouting(for screen: Screen) -> Bool {
        if !appConfiguration.session.isValid {
            if appConfiguration.session.hasPassword() && appConfiguration.session.authenticatedUser != nil {
                return open(
                    .choosePassword(mode: .login, route: screen),
                    by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
                ) != nil
            } else {
                return open(.introduction(mode: .initialize), by: .launch, animated: false) != nil
            }
        } else {
            switch screen {
            case .addContact,
                 .sendAlgosTransactionPreview,
                 .assetSupportAlert,
                 .sendAssetTransactionPreview:
                tabBarViewController.route = screen
                tabBarViewController.routeForDeeplink()
                return true
            default:
                break
            }
            
            return false
        }
    }
    
    func openAccount(with address: String) {
        guard let account = appConfiguration.session.authenticatedUser?.account(address: address) else {
            return
        }
        
        if !appConfiguration.session.isValid {
            if appConfiguration.session.hasPassword() && appConfiguration.session.authenticatedUser != nil {
                open(.choosePassword(
                    mode: .login, route: .assetDetail(account: account, assetDetail: nil)),
                     by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
                )
            } else {
                open(.introduction(mode: .initialize), by: .launch, animated: false)
            }
        } else {
            tabBarViewController.selectedIndex = 0
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
}
