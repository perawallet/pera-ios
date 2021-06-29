// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  RootViewController.swift

import UIKit

class RootViewController: UIViewController {
    
    private var shouldHideTestNetBanner: Bool {
        return tabBarViewController.parent == nil
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyleForNetwork(isTestNet: appConfiguration.api.isTestNet)
    }
    
    private lazy var pushNotificationController = PushNotificationController(api: appConfiguration.api)
    
    lazy var statusBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.zPosition = 1.0
        view.backgroundColor = Colors.General.testNetBanner
        return view
    }()

    let appConfiguration: AppConfiguration
    
    private var router: Router?

    private let onceWhenViewDidAppear = Once()

    private lazy var deepLinkRouter = DeepLinkRouter(rootViewController: self, appConfiguration: appConfiguration)
    
    private(set) lazy var tabBarViewController = TabBarController(configuration: appConfiguration.all())
    
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
        view.backgroundColor = Colors.Background.primary

        initializeNetwork()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        onceWhenViewDidAppear.execute {
            changeUserInterfaceStyle(to: appConfiguration.api.session.userInterfaceStyle)
            addBanner()
            deepLinkRouter.initializeFlow()
        }
    }
}

extension RootViewController {
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
        tabBarViewController.routeForDeeplink()
        tabBarViewController.didMove(toParent: self)
    }
}

extension RootViewController {
    func handleDeepLinkRouting(for screen: Screen) -> Bool {
        return deepLinkRouter.handleDeepLinkRouting(for: screen)
    }

    func openAsset(from notification: NotificationDetail, for account: String) {
        deepLinkRouter.openAsset(from: notification, for: account)
    }
}

extension RootViewController: AlgorandNetworkUpdatable { }

extension RootViewController: BannerDisplayable {
    var shouldDisplayBanner: Bool {
        return appConfiguration.api.isTestNet
    }
}

extension RootViewController: WalletConnectRequestHandlerDelegate {
    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectRequestHandler,
        shouldSignFor transactionParameter: WCTransactionParams,
        fromDappSession url: WalletConnectURL
    ) {
        guard let transaction = transactionParameter.transaction,
              let account = appConfiguration.session.accounts.first(of: \.address, equalsTo: transaction.sender),
              let wcSession = appConfiguration.walletConnector.getWalletConnectSession(with: url) else {
            return
        }

        let fullScreenPresentation = Screen.Transition.Open.customPresent(
            presentationStyle: .fullScreen,
            transitionStyle: nil,
            transitioningDelegate: nil
        )

        switch transaction.transactionType {
        case .algos:
            open(
                .wcAlgosTransaction(
                    transactionParameter: transactionParameter,
                    account: account,
                    wcSession: wcSession
                ),
                by: fullScreenPresentation
            )
        case .asset:
            open(
                .wcAssetTransaction(
                    transactionParameter: transactionParameter,
                    account: account,
                    wcSession: wcSession
                ),
                by: fullScreenPresentation
            )
        case .assetAddition:
            open(
                .wcAssetAdditionTransaction(
                    transactionParameter: transactionParameter,
                    account: account,
                    wcSession: wcSession
                ),
                by: fullScreenPresentation
            )
        case .appCall:
            open(.wcAppCall(transactionParameter: transactionParameter, account: account, wcSession: wcSession), by: fullScreenPresentation)
        default:
            break
        }
    }

    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectRequestHandler,
        shouldSignFor transactionParameters: [WCTransactionParams],
        fromDappSession url: WalletConnectURL
    ) {
        let fullScreenPresentation = Screen.Transition.Open.customPresent(
            presentationStyle: .fullScreen,
            transitionStyle: nil,
            transitioningDelegate: nil
        )

        open(.wcGroupTransaction(transactionParameters: transactionParameters), by: fullScreenPresentation)
    }

    func walletConnectRequestHandler(_ walletConnectRequestHandler: WalletConnectRequestHandler, didReject request: WalletConnectRequest) {

    }

    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectRequestHandler,
        didInvalidate request: WalletConnectRequest
    ) {

    }
}

extension RootViewController: UserInterfaceChangable { }

extension RootViewController {
    func deleteAllData() {
        appConfiguration.session.reset(isContactIncluded: true)
        NotificationCenter.default.post(name: .ContactDeletion, object: self, userInfo: nil)
        pushNotificationController.revokeDevice()
    }
}
