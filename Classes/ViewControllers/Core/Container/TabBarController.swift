//
//  TabBarController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    private(set) lazy var accountsNavigationController = NavigationController(
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
    
    private let configuration: ViewControllerConfiguration
    
    var selectedTab: Tab {
        return Tab(rawValue: selectedIndex) ?? .accounts
    }
    
    var route: Screen?
    
    private var assetAlertDraft: AssetAlertDraft?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setValue(customTabBar, forKey: "tabBar")
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBar.layer.shadowRadius = 10
        tabBar.layer.shadowColor = Colors.shadowColor.cgColor
        tabBar.layer.shadowOpacity = 1.0
        tabBar.layer.masksToBounds = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        if let appConfiguration = UIApplication.shared.appConfiguration {
            appConfiguration.session.isValid = true
        }
        
        routeForDeeplink()
    }
}

extension TabBarController {
    private func setupTabBarController() {
        delegate = self
        viewControllers = [
            accountsNavigationController,
            historyNavigationController,
            contactsNavigationController,
            settingsNavigationController
        ]
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
    
    private func configureAppearance() {
        let fontAttributes = [NSAttributedString.Key.font: UIFont.font(.avenir, withWeight: .demiBold(size: 10.0))]
        UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .selected)
    }
}

extension TabBarController {
    func routeForDeeplink() {
        if let route = route {
            self.route = nil
            switch route {
            case .addContact:
                selectedIndex = 2
                topMostController?.open(route, by: .push)
            case .sendAlgosTransactionPreview,
                 .sendAssetTransactionPreview:
                selectedIndex = 0
                topMostController?.open(route, by: .push)
            case .assetSupportAlert:
                selectedIndex = 0
                open(
                    route,
                    by: .customPresentWithoutNavigationController(
                        presentationStyle: .overCurrentContext,
                        transitionStyle: .crossDissolve,
                        transitioningDelegate: nil
                    )
                )
            case .assetDetail:
                topMostController?.open(route, by: .push)
            case let .assetCancellableSupportAlert(draft):
                let controller = topMostController?.open(
                    route,
                    by: .customPresentWithoutNavigationController(
                        presentationStyle: .overCurrentContext,
                        transitionStyle: .crossDissolve,
                        transitioningDelegate: nil
                    )
                ) as? AssetCancellableSupportAlertViewController
                
                assetAlertDraft = draft
                
                controller?.delegate = self
            default:
                break
            }
        }
    }
}

extension TabBarController: UITabBarControllerDelegate {
    
}

extension TabBarController: AssetCancellableSupportAlertViewControllerDelegate {
    func assetCancellableSupportAlertViewControllerDidTapOKButton(
        _ assetCancellableSupportAlertViewController: AssetCancellableSupportAlertViewController
    ) {
        guard let account = assetAlertDraft?.account,
            let assetId = assetAlertDraft?.assetIndex,
            let api = UIApplication.shared.appConfiguration?.api else {
                return
        }
        
        let transactionController = TransactionController(api: api)
        
        let assetTransactionDraft = AssetTransactionSendDraft(from: account, assetIndex: Int64(assetId))
        transactionController.setAssetTransactionDraft(assetTransactionDraft)
        transactionController.composeAssetTransactionData(transactionType: .assetAddition)
        assetAlertDraft = nil
    }
}

extension TabBarController {
    enum Tab: Int {
        case accounts = 0
        case history = 1
        case contacts = 2
        case settings = 3
    }
}

extension TabBarController {
    private enum Colors {
        static let shadowColor = rgba(0.24, 0.27, 0.32, 0.1)
    }
}
