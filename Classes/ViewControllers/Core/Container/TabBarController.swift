//
//  TabBarController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    private lazy var accountsNavigationController = NavigationController(
        rootViewController: AccountsViewController(configuration: configuration)
    )
    
    private lazy var historyNavigationController = NavigationController(
        rootViewController: HistoryViewController(configuration: configuration)
    )
    
    private lazy var contactsNavigationController = NavigationController(
        rootViewController: ContactsViewController(configuration: configuration)
    )

    private lazy var settingsNavigationController = NavigationController(
        rootViewController: SettingsViewController(configuration: configuration)
    )
    
    lazy var activeNavigationController: NavigationController = accountsNavigationController
    
    private let configuration: ViewControllerConfiguration
    
    var selectedTab: Tab {
        return Tab(rawValue: selectedIndex) ?? .accounts
    }
    
    init(configuration: ViewControllerConfiguration, selectedTab: Tab = .accounts) {
        self.configuration = configuration
        
        super.init(nibName: nil, bundle: nil)
        
        setupTabBarController()
        
        configureAccountsTab()
        configureHistoryTab()
        configureContactsTab()
        configureSettingsTab()
        
        configureAppearance()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAppearance() {
        tabBar.clipsToBounds = true
        tabBar.isTranslucent = true
        tabBar.barTintColor = .white
        tabBar.tintColor = SharedColors.black
        tabBar.unselectedItemTintColor = SharedColors.darkGray
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
    
    private func configureContactsTab() {
        contactsNavigationController.tabBarItem = UITabBarItem(
            title: "tabbar-item-contacts".localized,
            image: img("tabbar-icon-contacts")?.withRenderingMode(.alwaysOriginal),
            selectedImage: img("tabbar-icon-contacts-selected")?.withRenderingMode(.alwaysOriginal)
        )
        
        contactsNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 1.5, left: 0.0, bottom: -1.5, right: 0.0)
        contactsNavigationController.tabBarItem.tag = 2
    }
    
    private func configureSettingsTab() {
        settingsNavigationController.tabBarItem = UITabBarItem(
            title: "tabbar-item-settings".localized,
            image: img("tabbar-icon-settings")?.withRenderingMode(.alwaysOriginal),
            selectedImage: img("tabbar-icon-settings-selected")?.withRenderingMode(.alwaysOriginal)
        )
        
        settingsNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 2.0, left: 0.0, bottom: -2.0, right: 0.0)
        settingsNavigationController.tabBarItem.tag = 3
    }
    
    private func setupTabBarController() {
        delegate = self
        
        viewControllers = [
            accountsNavigationController, historyNavigationController, contactsNavigationController, settingsNavigationController
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

extension TabBarController: UITabBarControllerDelegate {
    
}

extension TabBarController {
    
    enum Tab: Int {
        case accounts = 0
        case history = 1
        case contacts = 2
        case settings = 3
    }
}
