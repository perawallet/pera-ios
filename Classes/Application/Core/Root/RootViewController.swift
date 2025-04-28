// Copyright 2022-2025 Pera Wallet, LDA

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

import Foundation
import MacaroonUIKit
import MacaroonUtils
import UIKit

final class RootViewController:
    UIViewController,
    NotificationObserver {
    var notificationObservations: [NSObjectProtocol] = []
    
    private(set) var isInAppBrowserActive = false
    
    var areTabsVisible: Bool {
        return !mainContainer.items.isEmpty
    }

    private(set) var isDisplayingGovernanceBanner = true

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return determinePreferredStatusBarStyle(for: appConfiguration.api.network)
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return areTabsVisible ? mainContainer.preferredStatusBarUpdateAnimation : .fade
    }
    override var childForStatusBarStyle: UIViewController? {
        return areTabsVisible ? mainContainer : nil
    }
    override var childForStatusBarHidden: UIViewController? {
        return areTabsVisible ? mainContainer : nil
    }

    private(set) lazy var mainContainer = TabBarController(
        swapDataStore: SwapDataLocalStore(),
        analytics: appConfiguration.analytics,
        api: appConfiguration.api,
        bannerController: appConfiguration.bannerController,
        loadingController: appConfiguration.loadingController,
        session: appConfiguration.session,
        sharedDataController: appConfiguration.sharedDataController,
        appLaunchController: appConfiguration.launchController,
        featureFlagService: appConfiguration.featureFlagService
    )

    private lazy var pushNotificationController = PushNotificationController(
        target: target,
        session: appConfiguration.session,
        api: appConfiguration.api
    )

    private(set) lazy var walletConnectV2RequestHandler: WalletConnectV2RequestHandler = {
        let handler = WalletConnectV2RequestHandler(analytics: appConfiguration.analytics)
        handler.delegate = self
        return handler
    }()

    typealias HasOngoingWCRequest = Bool
    var sessionsForOngoingWCRequests: [WalletConnectTopic: HasOngoingWCRequest] = [:]

    var transitionToWCTransactionSignSuccessful: BottomSheetTransition?
    var wcArbitraryDataSuccessTransition: BottomSheetTransition?

    let target: ALGAppTarget
    let appConfiguration: AppConfiguration
    let launchController: AppLaunchController

    init(
        target: ALGAppTarget,
        appConfiguration: AppConfiguration,
        launchController: AppLaunchController
    ) {
        self.target = target
        self.appConfiguration = appConfiguration
        self.launchController = launchController

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        build()
        observeNotifications()
    }
}

extension RootViewController {
    func launchTabsIfNeeded() {
        if areTabsVisible {
            return
        }

        let configuration = appConfiguration.all()
        let announcementAPIDataController = AnnouncementAPIDataController(
            api: configuration.api!,
            session: configuration.session!
        )
        let incomingASAsAPIDataController = IncomingASAsAPIDataController(
            api: configuration.api!,
            session: configuration.session!
        )        
        let homeViewController = HomeViewController(
            swapDataStore: SwapDataLocalStore(),
            dataController: HomeAPIDataController(
                sharedDataController: appConfiguration.sharedDataController,
                session: appConfiguration.session,
                announcementDataController: announcementAPIDataController,
                incomingASAsAPIDataController: incomingASAsAPIDataController
            ),
            copyToClipboardController: ALGCopyToClipboardController(
                toastPresentationController: appConfiguration.toastPresentationController
            ),
            configuration: configuration
        )
        let homeTab = HomeTabBarItem(
            NavigationContainer(rootViewController: homeViewController)
        )
        
        let discoverViewController = DiscoverHomeScreen(configuration: configuration)
        let discoverTab = DiscoverTabBarItem(
            NavigationContainer(rootViewController: discoverViewController)
        )

        let collectibleListQuery = CollectibleListQuery(
            filteringBy: .init(),
            sortingBy: appConfiguration.sharedDataController.selectedCollectibleSortingAlgorithm
        )
        let collectibleListViewController = CollectiblesViewController(
            query: collectibleListQuery,
            dataController: CollectibleListLocalDataController(
                galleryAccount: .all,
                sharedDataController: appConfiguration.sharedDataController
            ),
            copyToClipboardController: ALGCopyToClipboardController(
                toastPresentationController: appConfiguration.toastPresentationController
            ),
            configuration: configuration
        )
        let collectiblesTab =
            CollectiblesTabBarItem(NavigationContainer(rootViewController: collectibleListViewController))

        let settingsViewController = SettingsViewController(configuration: configuration)
        let settingsTab =
            SettingsTabBarItem(NavigationContainer(rootViewController: settingsViewController))

        mainContainer.items = [
            homeTab,
            discoverTab,
            FixedSpaceTabBarItem(width: .noMetric),
            collectiblesTab,
            settingsTab
        ]

        setNeedsDiscoverTabBarItemUpdateIfNeeded()
    }

    func launch(
        tab: TabBarItemID
    ) {
        mainContainer.selectedTab = tab
    }

    func terminateTabs() {
        mainContainer.items = []
    }
}

extension RootViewController {
    private func build() {
        addBackground()
        addMain()
    }

    private func addBackground() {
        view.backgroundColor = Colors.Defaults.background.uiColor
    }

    private func addMain() {
        addContent(mainContainer) {
            contentView in
            view.addSubview(contentView)
            contentView.snp.makeConstraints {
                $0.top == 0
                $0.leading == 0
                $0.bottom == 0
                $0.trailing == 0
            }
        }
    }
    
    private func observeNotifications() {
        observe(notification: .inAppBrowserAppeared) {
            [weak self] notification in
            guard let self = self else { return }
            
            self.isInAppBrowserActive = true
        }
        
        observe(notification: .inAppBrowserDisappeared) {
            [weak self] notification in
            guard let self = self else { return }
            
            self.isInAppBrowserActive = false
        }
    }
}

extension RootViewController {
    private func setNeedsDiscoverTabBarItemUpdateIfNeeded() {
        mainContainer.setNeedsDiscoverTabBarItemUpdateIfNeeded()
    }
}

extension RootViewController {
    func deleteAllData(
        onCompletion handler: @escaping BoolHandler
    ) {
        appConfiguration.loadingController.startLoadingWithMessage(String(localized: "title-loading"))

        appConfiguration.sharedDataController.stopPolling()

        pushNotificationController.revokeDevice() { [weak self] isCompleted in
            guard let self = self else {
                return
            }

            if isCompleted {
                self.appConfiguration.session.reset(includingContacts: true)

                self.appConfiguration.peraConnect.disconnectFromAllSessions()

                self.appConfiguration.sharedDataController.resetPolling()

                NotificationCenter.default.post(name: .ContactDeletion, object: self, userInfo: nil)
            } else {
                self.appConfiguration.sharedDataController.startPolling()
            }

             self.appConfiguration.loadingController.stopLoading()
             handler(isCompleted)
        }
    }
}
