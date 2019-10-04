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
    
    func addAccount(_ account: Account) {
        if let viewController = tabBarViewController.accountsNavigationController.viewControllers.first as? AccountsViewController {
            viewController.newAccount = account
        }
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
            UIApplication.topViewController()?.tabBarController?.selectedIndex = 0
            
            if let controller = UIApplication.topViewController(),
                let navigationController = controller.presentingViewController as? NavigationController,
                let tabBarController = navigationController.viewControllers.first as? TabBarController,
                let accountsViewController = tabBarController.accountsNavigationController.viewControllers.first {
                    
                controller.dismiss(animated: false) {
                    accountsViewController.open(screen, by: .set, animated: false)
                }
                
                return true
            } else {
                return UIApplication.topViewController()?.open(screen, by: .set, animated: false) != nil
            }
        }
    }
    
    func openAccount(with address: String) {
        guard let account = appConfiguration.session.authenticatedUser?.account(address: address) else {
            return
        }
        
        if !appConfiguration.session.isValid {
            if appConfiguration.session.hasPassword() && appConfiguration.session.authenticatedUser != nil {
                open(.choosePassword(
                    mode: .login, route: .accounts(account: account)),
                     by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
                )
            } else {
                open(.introduction(mode: .initialize), by: .launch, animated: false)
            }
        } else {
            tabBarViewController.selectedIndex = 0
            
            if let controller = UIApplication.topViewController(),
                let navigationController = controller.presentingViewController as? NavigationController,
                let tabBarController = navigationController.viewControllers.first as? TabBarController,
                let accountsViewController = tabBarController.accountsNavigationController.viewControllers.first {
                
                controller.dismiss(animated: false) {
                    (accountsViewController as? AccountsViewController)?.selectedAccount = account
                }
            } else {
                if let viewController = tabBarViewController.accountsNavigationController.viewControllers.first as? AccountsViewController,
                    let selectedAccount = viewController.accountSelectionViewController.selectedAccount,
                        selectedAccount.address != account.address {
                        viewController.accountSelectionViewController.selectedAccount = account
                        viewController.accountSelectionViewController.accountsCollectionView.reloadData()
                        viewController.updateSelectedAccount(account)
                }
            }
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
