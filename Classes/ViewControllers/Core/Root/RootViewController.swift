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

        changeUserInterfaceStyle(to: appConfiguration.api.session.userInterfaceStyle)
        initializeNetwork()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        onceWhenViewDidAppear.execute {
            addBanner()
            initializeFlow()
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
    private func initializeFlow() {
        if !appConfiguration.session.isValid {
            if appConfiguration.session.hasPassword() && appConfiguration.session.authenticatedUser != nil {
                open(
                   .choosePassword(mode: .login, flow: nil, route: nil),
                   by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
               )
            } else {
                appConfiguration.session.reset(isContactIncluded: false)
                open(.introduction(flow: .initializeAccount(mode: nil)), by: .launch, animated: false)
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

extension RootViewController: UserInterfaceChangable { }

extension RootViewController {
    func deleteAllData() {
        appConfiguration.session.reset(isContactIncluded: true)
        NotificationCenter.default.post(name: .ContactDeletion, object: self, userInfo: nil)
        pushNotificationController.revokeDevice()
    }
}
