//
//  TabBarController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    // MARK: Variables
    
    private(set) lazy var accountsNavigationController = NavigationController(
        rootViewController: AccountsViewController(configuration: configuration)
    )
    
    private lazy var historyNavigationController = NavigationController(
        rootViewController: HistoryViewController(configuration: configuration)
    )
    
    private lazy var auctionNavigationController = NavigationController(
        rootViewController: AuctionViewController(configuration: configuration)
    )
    
    private lazy var contactsNavigationController = NavigationController(
        rootViewController: ContactsViewController(configuration: configuration)
    )

    private lazy var settingsNavigationController = NavigationController(
        rootViewController: SettingsViewController(configuration: configuration)
    )
    
    private let configuration: ViewControllerConfiguration
    
    var selectedTab: Tab {
        return Tab(rawValue: selectedIndex) ?? .accounts
    }
    
    private let route: Screen?
    
    // MARK: Components
    
    private lazy var customTabBar: TabBar = {
        let tabBar = TabBar()
        tabBar.delegate = self
        tabBar.backgroundColor = .white
        tabBar.barTintColor = .white
        tabBar.clipsToBounds = true
        tabBar.tintColor = SharedColors.black
        tabBar.unselectedItemTintColor = SharedColors.darkGray
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        return tabBar
    }()
    
    // MARK: Initialization
    
    init(route: Screen?, configuration: ViewControllerConfiguration, selectedTab: Tab = .accounts) {
        self.route = route
        self.configuration = configuration
        
        super.init(nibName: nil, bundle: nil)
        
        setupTabBarController()
        
        configureAccountsTab()
        configureHistoryTab()
        configureAuctionTab()
        configureContactsTab()
        configureSettingsTab()
        
        configureAppearance()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    private func setupTabBarController() {
        delegate = self
        
        let controllers = [
            accountsNavigationController,
            historyNavigationController,
            auctionNavigationController,
            contactsNavigationController,
            settingsNavigationController
        ]
        
        viewControllers = controllers
    }
    
    private func configureAccountsTab() {
        accountsNavigationController.tabBarItem = UITabBarItem(
            title: "tabbar-item-accounts".localized,
            image: img("tabbar-icon-accounts")?.withRenderingMode(.alwaysOriginal),
            selectedImage: img("tabbar-icon-accounts-selected")?.withRenderingMode(.alwaysOriginal)
        )
        
        accountsNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 2.0, left: 0.0, bottom: -2.0, right: 0.0)
        accountsNavigationController.tabBarItem.tag = 0
    }
    
    private func configureHistoryTab() {
        historyNavigationController.tabBarItem = UITabBarItem(
            title: "tabbar-item-history".localized,
            image: img("tabbar-icon-history")?.withRenderingMode(.alwaysOriginal),
            selectedImage: img("tabbar-icon-history-selected")?.withRenderingMode(.alwaysOriginal)
        )
        
        historyNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 2.0, left: 0.0, bottom: -2.0, right: 0.0)
        historyNavigationController.tabBarItem.tag = 1
    }
    
    private func configureAuctionTab() {
        auctionNavigationController.tabBarItem = UITabBarItem(
            title: "tabbar-item-auction".localized,
            image: img("tabbar-icon-auction")?.withRenderingMode(.alwaysOriginal),
            selectedImage: img("tabbar-icon-auction-selected")?.withRenderingMode(.alwaysOriginal)
        )
        
        auctionNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 2.0, left: 0.0, bottom: -2.0, right: 0.0)
        auctionNavigationController.tabBarItem.tag = 2
    }
    
    private func configureContactsTab() {
        contactsNavigationController.tabBarItem = UITabBarItem(
            title: "tabbar-item-contacts".localized,
            image: img("tabbar-icon-contacts")?.withRenderingMode(.alwaysOriginal),
            selectedImage: img("tabbar-icon-contacts-selected")?.withRenderingMode(.alwaysOriginal)
        )
        
        contactsNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 1.5, left: 0.0, bottom: -1.5, right: 0.0)
        contactsNavigationController.tabBarItem.tag = 3
    }
    
    private func configureSettingsTab() {
        settingsNavigationController.tabBarItem = UITabBarItem(
            title: "tabbar-item-settings".localized,
            image: img("tabbar-icon-settings")?.withRenderingMode(.alwaysOriginal),
            selectedImage: img("tabbar-icon-settings-selected")?.withRenderingMode(.alwaysOriginal)
        )
        
        settingsNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 2.0, left: 0.0, bottom: -2.0, right: 0.0)
        settingsNavigationController.tabBarItem.tag = 4
    }
    
    private func configureAppearance() {
        let fontAttributes = [NSAttributedString.Key.font: UIFont.font(.avenir, withWeight: .demiBold(size: 10.0))]
        UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .selected)
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setValue(customTabBar, forKey: "tabBar")
        
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBar.layer.shadowRadius = 10
        tabBar.layer.shadowColor = rgba(0.67, 0.67, 0.72, 0.35).cgColor
        tabBar.layer.shadowOpacity = 1.0
        tabBar.layer.masksToBounds = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        if let appConfiguration = UIApplication.shared.appConfiguration {
            appConfiguration.session.isValid = true
        }
        
        if let route = route {
            guard let accountsViewController = accountsNavigationController.viewControllers.first as? AccountsViewController else {
                return
            }
            
            accountsViewController.route = route
        }
    }
}

// MARK: UITabBarControllerDelegate

extension TabBarController: UITabBarControllerDelegate {
    
}

// MARK: Tab

extension TabBarController {
    
    enum Tab: Int {
        case accounts = 0
        case history = 1
        case auction = 2
        case contacts = 3
        case settings = 4
    }
}
