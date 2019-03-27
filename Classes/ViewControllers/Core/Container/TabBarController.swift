//
//  TabBarController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func removeFromParentController() {
        self.willMove(toParent: nil)
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
}

protocol TabBarControllerDelegate: class {
    func tabBarController(_ controller: TabBarController, didSelectTabBar item: TabBar.Item)
}

class TabBarController: BaseViewController {
    
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
    
    lazy var tabBar = TabBar()
    
    private var activeTabBarItem: TabBar.Item = .accounts
    
    lazy var activeNavigationController: NavigationController = accountsNavigationController
    
    weak var delegate: TabBarControllerDelegate?
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupTabBarLayout()
        
        view.backgroundColor = rgba(0.67, 0.67, 0.72, 0.2)
        
        updateLayout(with: .accounts)
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        
        tabBar.delegate = self
    }
    
    // MARK: Layout setup
    
    func setupTabBarLayout() {
        let items: [TabBar.Item] = [
            TabBar.Item.accounts,
            TabBar.Item.history,
            TabBar.Item.contacts,
            TabBar.Item.settings
        ]
        
        tabBar.setupLayout(with: items)
        
        view.addSubview(tabBar)
        
        tabBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func updateLayout(with activeTabBarItem: TabBar.Item) {
        tabBar.select(activeTabBarItem)
        
        activeNavigationController.removeFromParentController()
        
        switch activeTabBarItem {
        case .accounts:
            activeNavigationController = accountsNavigationController
        case .history:
            activeNavigationController = historyNavigationController
        case .contacts:
            activeNavigationController = contactsNavigationController
        case .settings:
            activeNavigationController = settingsNavigationController
        }
        
        setupActiveViewControllerLayout()
    }
    
    private func setupActiveViewControllerLayout() {
        addChild(activeNavigationController)
        
        view.insertSubview(activeNavigationController.view, at: 0)
        
        activeNavigationController.view.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(tabBar.snp.top)
        }
        
        activeNavigationController.didMove(toParent: self)
    }
    
    @discardableResult
    func select(tab item: TabBar.Item) -> UIViewController {
        tabBar.select(item)
        
        if self.activeTabBarItem == item {
            return activeNavigationController
        }
        
        self.activeTabBarItem = item
        
        updateLayout(with: activeTabBarItem)
        
        return activeNavigationController
    }
}

extension TabBarController: TabBarDelegate {
    
    func tabBar(_ view: TabBar, didSelect item: TabBar.Item) {
        if self.activeTabBarItem == item {
            return
        }
        
        tabBar.select(item)
        
        self.activeTabBarItem = item
        
        updateLayout(with: activeTabBarItem)
        
        delegate?.tabBarController(self, didSelectTabBar: item)
    }
}
