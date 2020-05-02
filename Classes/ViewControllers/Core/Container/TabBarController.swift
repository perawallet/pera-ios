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
    
    private lazy var contactsNavigationController = NavigationController(
        rootViewController: ContactsViewController(configuration: configuration)
    )

    private lazy var notificationsNavigationController = NavigationController(
        rootViewController: NotificationsViewController(configuration: configuration)
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
        tabBar.clipsToBounds = false
        tabBar.tintColor = SharedColors.primary
        tabBar.unselectedItemTintColor = SharedColors.gray900
        
        if #available(iOS 13, *) {
            let appearance = tabBar.standardAppearance.copy()
            appearance.backgroundImage = UIImage()
            appearance.shadowImage = UIImage()
            appearance.shadowColor = .clear
            tabBar.standardAppearance = appearance
        } else {
            tabBar.shadowImage = UIImage()
            tabBar.backgroundImage = UIImage()
        }

        return tabBar
    }()
    
    init(configuration: ViewControllerConfiguration, selectedTab: Tab = .accounts) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
        setupTabBarController()
        configureAccountsTab()
        configureContactsTab()
        configureNotificationsTab()
        configureSettingsTab()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setValue(customTabBar, forKey: "tabBar")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tabBar.applyShadow(Shadow(color: Colors.shadowColor, offset: CGSize(width: 0.0, height: 4.0), radius: 16.0, opacity: 1.0))
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
            contactsNavigationController,
            notificationsNavigationController,
            settingsNavigationController
        ]
    }
    
    private func configureAccountsTab() {
        accountsNavigationController.tabBarItem = UITabBarItem(
            title: "",
            image: img("tabbar-icon-accounts")?.withRenderingMode(.alwaysOriginal),
            selectedImage: img("tabbar-icon-accounts-selected")?.withRenderingMode(.alwaysOriginal)
        )
        
        accountsNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        accountsNavigationController.tabBarItem.tag = 0
    }
    
    private func configureContactsTab() {
        contactsNavigationController.tabBarItem = UITabBarItem(
            title: "",
            image: img("tabbar-icon-contacts")?.withRenderingMode(.alwaysOriginal),
            selectedImage: img("tabbar-icon-contacts-selected")?.withRenderingMode(.alwaysOriginal)
        )
        
        contactsNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        contactsNavigationController.tabBarItem.tag = 1
    }
    
    private func configureNotificationsTab() {
        notificationsNavigationController.tabBarItem = UITabBarItem(
            title: "",
            image: img("tabbar-icon-notifications")?.withRenderingMode(.alwaysOriginal),
            selectedImage: img("tabbar-icon-notifications-selected")?.withRenderingMode(.alwaysOriginal)
        )
        
        notificationsNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        notificationsNavigationController.tabBarItem.tag = 2
    }
    
    private func configureSettingsTab() {
        settingsNavigationController.tabBarItem = UITabBarItem(
            title: "",
            image: img("tabbar-icon-settings")?.withRenderingMode(.alwaysOriginal),
            selectedImage: img("tabbar-icon-settings-selected")?.withRenderingMode(.alwaysOriginal)
        )
        
        settingsNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        settingsNavigationController.tabBarItem.tag = 3
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
        transactionController.setTransactionDraft(assetTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetAddition)
        assetAlertDraft = nil
    }
}

extension TabBarController {
    enum Tab: Int {
        case accounts = 0
        case contacts = 1
        case notifications = 2
        case settings = 3
    }
}

extension TabBarController {
    private enum Colors {
        static let shadowColor = rgba(0.0, 0.0, 0.0, 0.1)
    }
}
