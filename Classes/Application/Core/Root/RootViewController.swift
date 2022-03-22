// Copyright 2022 Pera Wallet, LDA

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
import MacaroonTabBarController
import MacaroonUIKit
import MacaroonUtils
import UIKit

class RootViewController: UIViewController {
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
    
    private lazy var mainContainer = TabBarController()
    
    private lazy var pushNotificationController = PushNotificationController(
        session: appConfiguration.session,
        api: appConfiguration.api,
        bannerController: appConfiguration.bannerController
    )

    private var currentWCTransactionRequest: WalletConnectRequest?
    private var wcRequestScreen: WCMainTransactionScreen?
    private var wcTransactionSuccessTransition: BottomSheetTransition?
    
    let appConfiguration: AppConfiguration
    let launchController: AppLaunchController

    init(
        appConfiguration: AppConfiguration,
        launchController: AppLaunchController
    ) {
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
    }
}

extension RootViewController {
    func launchTabsIfNeeded() {
        if areTabsVisible {
            return
        }
        
        let configuration = appConfiguration.all()

        let homeViewController = HomeViewController(
            dataController: HomeAPIDataController(appConfiguration.sharedDataController),
            configuration: configuration
        )
        let homeTab = HomeTabBarItem(NavigationController(rootViewController: homeViewController))
        
        let algoStatisticsViewController =
            AlgoStatisticsViewController(
                dataController: AlgoStatisticsDataController(
                    api: appConfiguration.api,
                    sharedDataController: appConfiguration.sharedDataController
                ),
                configuration: configuration
            )
        let algoStatisticsTab = AlgoStatisticsTabBarItem(
            NavigationController(rootViewController: algoStatisticsViewController)
        )
        
        let contactsViewController = ContactsViewController(configuration: configuration)
        let contactsTab =
            ContactsTabBarItem(NavigationController(rootViewController: contactsViewController))
        
        let settingsViewController = SettingsViewController(configuration: configuration)
        let settingsTab =
            SettingsTabBarItem(NavigationController(rootViewController: settingsViewController))
        
        mainContainer.items = [
            homeTab,
            algoStatisticsTab,
            FixedSpaceTabBarItem(width: .noMetric),
            contactsTab,
            settingsTab
        ]
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
    func hideGovernanceBanner() {
        isDisplayingGovernanceBanner = false
    }
}

extension RootViewController: WalletConnectRequestHandlerDelegate {
    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectRequestHandler,
        shouldSign transactions: [WCTransaction],
        for request: WalletConnectRequest,
        with transactionOption: WCTransactionOption?
    ) {
        openMainTransactionScreen(transactions, for: request, with: transactionOption)
    }

    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectRequestHandler,
        didInvalidate request: WalletConnectRequest
    ) {
        appConfiguration.walletConnector.rejectTransactionRequest(request, with: .invalidInput(.parse))
    }

    private func openMainTransactionScreen(
        _ transactions: [WCTransaction],
        for request: WalletConnectRequest,
        with transactionOption: WCTransactionOption?
    ) {
        openMainViewController(animated: true, for: transactions, with: request, and: transactionOption)

//        if let currentWCTransactionRequest = currentWCTransactionRequest {
//            if currentWCTransactionRequest.isSameTransactionRequest(with: request) {
//                return
//            }
//
//            appConfiguration.walletConnector.rejectTransactionRequest(currentWCTransactionRequest, with: .rejected(.alreadyDisplayed))
//
//            wcRequestScreen?.closeScreen(by: .dismiss, animated: false) {
//                self.openMainViewController(animated: false, for: transactions, with: request, and: transactionOption)
//            }
//        } else {
//            openMainViewController(animated: true, for: transactions, with: request, and: transactionOption)
//        }
    }

    private func openMainViewController(
        animated: Bool,
        for transactions: [WCTransaction],
        with request: WalletConnectRequest,
        and transactionOption: WCTransactionOption?
    ) {
        currentWCTransactionRequest = request
        
        let draft = WalletConnectRequestDraft(
            request: request,
            transactions: transactions,
            option: transactionOption
        )
        launchController.receive(deeplinkWithSource: .walletConnectRequest(draft))
    }
}

extension RootViewController: WCMainTransactionScreenDelegate {
    func wcMainTransactionScreen(
        _ wcMainTransactionScreen: WCMainTransactionScreen,
        didRejected request: WalletConnectRequest
    ) {
        resetCurrentWCTransaction()
        wcMainTransactionScreen.dismissScreen()
    }

    func wcMainTransactionScreen(
        _ wcMainTransactionScreen: WCMainTransactionScreen,
        didSigned request: WalletConnectRequest,
        in session: WCSession?
    ) {
        resetCurrentWCTransaction()

        guard let wcSession = session else {
            return
        }

        wcMainTransactionScreen.dismissScreen {
            [weak self] in
            guard let self = self else { return }
            
            self.presentWCTransactionSuccessMessage(for: wcSession)
        }
    }

    private func presentWCTransactionSuccessMessage(for session: WCSession) {
        let dappName = session.peerMeta.name
        let configurator = BottomWarningViewConfigurator(
            image: "icon-approval-check".uiImage,
            title: "wc-transaction-request-signed-warning-title".localized,
            description: .plain(
                "wc-transaction-request-signed-warning-message".localized(dappName, dappName)
            ),
            primaryActionButtonTitle: nil,
            secondaryActionButtonTitle: "title-close".localized
        )
        let transition = BottomSheetTransition(presentingViewController: findVisibleScreen())
        
        transition.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )
        
        self.wcTransactionSuccessTransition = transition
    }

    private func resetCurrentWCTransaction() {
        currentWCTransactionRequest = nil
        wcRequestScreen = nil
    }
}

extension RootViewController {
    func deleteAllData(
        onCompletion handler: @escaping BoolHandler
    ) {
        appConfiguration.loadingController.startLoadingWithMessage("title-loading".localized)

        appConfiguration.sharedDataController.stopPolling()

        pushNotificationController.revokeDevice() { [weak self] isCompleted in
            guard let self = self else {
                return
            }

            if isCompleted {
                self.appConfiguration.session.reset(includingContacts: true)
                self.appConfiguration.walletConnector.resetAllSessions()
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

extension RootViewController {
    private func build() {
        addBackground()
        addMain()
    }
    
    private func addBackground() {
        view.backgroundColor = Colors.Background.primary
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
}

extension WalletConnectRequest {
    func isSameTransactionRequest(with request: WalletConnectRequest) -> Bool {
        if let firstId = id as? Int,
           let secondId = request.id as? Int {
            return firstId == secondId
        }

        if let firstId = id as? String,
           let secondId = request.id as? String {
            return firstId == secondId
        }

        if let firstId = id as? Double,
           let secondId = request.id as? Double {
            return firstId == secondId
        }

        return false
    }
}
