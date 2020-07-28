//
//  ViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    private var shouldHideTestNetBanner: Bool {
        return tabBarViewController.parent == nil
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    private lazy var pushNotificationController = PushNotificationController(api: appConfiguration.api)
    
    // MARK: Properties
    
    private lazy var statusbarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.zPosition = 1.0
        view.backgroundColor = SharedColors.testNetBanner
        return view
    }()

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
        
        view.backgroundColor = SharedColors.primaryBackground
        
        initializeNetwork()
        addTestNetBanner()
        
        if !appConfiguration.session.isValid {
            if appConfiguration.session.hasPassword() && appConfiguration.session.authenticatedUser != nil {
                open(
                    .choosePassword(mode: .login, route: nil),
                    by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
                )
            } else {
                appConfiguration.session.reset(isContactIncluded: false)
                open(.introduction, by: .launch, animated: false)
            }
        } else {
            setupTabBarController()
        }
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
                return open(.introduction, by: .launch, animated: false) != nil
            }
        } else {
            switch screen {
            case .addContact,
                 .sendAlgosTransactionPreview,
                 .assetSupport,
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
    
    func openAsset(from notification: NotificationDetail, for account: String) {
        if !appConfiguration.session.isValid {
            if appConfiguration.session.hasPassword() && appConfiguration.session.authenticatedUser != nil {
                if let notificationtype = notification.notificationType,
                    notificationtype == .assetSupportRequest {
                    open(.choosePassword(
                        mode: .login, route: .assetActionConfirmationNotification(address: account, assetId: notification.asset?.id)),
                         by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
                    )
                    return
                } else {
                    open(.choosePassword(
                        mode: .login, route: .assetDetailNotification(address: account, assetId: notification.asset?.id)),
                         by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
                    )
                }
            } else {
                open(.introduction, by: .launch, animated: false)
            }
        } else {
            guard let account = appConfiguration.session.account(from: account) else {
                return
            }
            
            var assetDetail: AssetDetail?
            
            if let assetId = notification.asset?.id {
                assetDetail = account.assetDetails.first { $0.id == assetId }
            }
            
            if let notificationtype = notification.notificationType,
                notificationtype == .assetSupportRequest {
                guard let assetId = notification.asset?.id else {
                    return
                }
                let draft = AssetAlertDraft(
                    account: account,
                    assetIndex: assetId,
                    assetDetail: nil,
                    title: "asset-support-add-title".localized,
                    detail: String(
                        format: "asset-support-add-message".localized,
                        "\(account.name ?? "")"
                    ),
                    actionTitle: "title-ok".localized
                )
                tabBarViewController.route = .assetActionConfirmation(assetAlertDraft: draft)
                tabBarViewController.routeForDeeplink()
                return
            } else {
                tabBarContainer?.selectedItem = tabBarContainer?.items[0]
                tabBarViewController.route = .assetDetail(account: account, assetDetail: assetDetail)
                tabBarViewController.routeForDeeplink()
            }
        }
    }

    @discardableResult
    func route<T: UIViewController>(
        to screen: Screen,
        from viewController: UIViewController,
        by style: Screen.Transition.Open,
        animated: Bool = true,
        then completion: EmptyHandler? = nil
    ) -> T? {
        return router?.route(to: screen, from: viewController, by: style, animated: animated, then: completion)
    }
}

extension RootViewController {
    private func initializeNetwork() {
        if let authenticatedUser = appConfiguration.session.authenticatedUser {
            if let preferredAlgorandNetwork = authenticatedUser.preferredAlgorandNetwork() {
                setNetwork(to: preferredAlgorandNetwork)
            } else {
                setNetworkFromTarget()
            }
        } else {
            setNetworkFromTarget()
        }
    }
    
    func setNetworkFromTarget() {
        if Environment.current.isTestNet {
            setNetwork(to: .testnet)
        } else {
            setNetwork(to: .mainnet)
        }
    }
    
    func setNetwork(to network: API.BaseNetwork) {
        appConfiguration.api.cancelAllEndpoints()
        appConfiguration.api.setupEnvironment(for: network)
    }
}

extension RootViewController {
    func addTestNetBanner() {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        if !appConfiguration.api.isTestNet {
            removeTestNetBanner()
            return
        }
        
        if statusbarView.superview != nil {
            return
        }
        
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        window.addSubview(statusbarView)
        
        statusbarView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(statusBarHeight)
            make.top.leading.trailing.equalToSuperview()
        }
    }
    
    func removeTestNetBanner() {
        if statusbarView.superview != nil {
            statusbarView.removeFromSuperview()
        }
    }
}

extension RootViewController {
    func deleteAllData() {
        appConfiguration.session.reset(isContactIncluded: true)
        NotificationCenter.default.post(name: .ContactDeletion, object: self, userInfo: nil)
        pushNotificationController.revokeDevice()
    }
}
