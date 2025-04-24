// Copyright 2025 Pera Wallet, LDA

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
//  TabBarController.swift

import Foundation
import MacaroonUIKit
import UIKit

final class TabBarController: TabBarContainer {
    var route: Screen?

    var selectedTab: TabBarItemID? {
        get {
            let item = items[safe: selectedIndex]
            return item.unwrap { TabBarItemID(rawValue: $0.id) }
        }
        set {
            selectedIndex = newValue.unwrap { items.index(of: $0) }
        }
    }

    private lazy var buySellAction = TransactionOptionListAction(
        viewModel: BuySellTransactionOptionListItemButtonViewModel()
    ) {
        [weak self] _ in
        guard let self = self else { return }
        self.navigateToBuySell()
    }

    private lazy var stakingActionViewModel = createStakingActionViewModel()
    private lazy var stakingAction = createStakingListAction()
    
    private lazy var swapActionViewModel = createSwapActionViewModel()
    private lazy var swapAction = createSwapListAction()

    private lazy var sendAction = TransactionOptionListAction(
        viewModel: SendTransactionOptionListItemButtonViewModel()
    ) {
        [weak self] _ in
        guard let self = self else { return }
        self.navigateToSendTransaction()
    }

    private lazy var receiveAction = TransactionOptionListAction(
        viewModel: ReceiveTransactionOptionListItemButtonViewModel()
    ) {
        [weak self] _ in
        guard let self = self else { return }
        self.navigateToReceiveTransaction()
    }

    private lazy var scanQRCodeAction = TransactionOptionListAction(
        viewModel: ScanQRCodeTransactionOptionListItemButtonViewModel()
    ) {
        [weak self] _ in
        guard let self = self else { return }
        self.navigateToQRScanner()
    }

    private lazy var browseDAppsAction = createBrowseDAppsListAction()
    
    private lazy var cardsAction = createCardsAction()

    private lazy var moonPayFlowCoordinator = MoonPayFlowCoordinator(presentingScreen: self)
    private lazy var meldFlowCoordinator = MeldFlowCoordinator(
        analytics: analytics,
        presentingScreen: self
    )
    private lazy var bidaliFlowCoordinator = BidaliFlowCoordinator(presentingScreen: self, api: api)

    private lazy var swapAssetFlowCoordinator = SwapAssetFlowCoordinator(
        draft: SwapAssetFlowDraft(),
        dataStore: swapDataStore,
        analytics: analytics,
        api: api,
        sharedDataController: sharedDataController,
        loadingController: loadingController,
        bannerController: bannerController,
        presentingScreen: self
    )
    private lazy var sendTransactionFlowCoordinator = SendTransactionFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController
    )
    private lazy var receiveTransactionFlowCoordinator = ReceiveTransactionFlowCoordinator(presentingScreen: self)
    private lazy var scanQRFlowCoordinator = ScanQRFlowCoordinator(
        analytics: analytics,
        api: api,
        bannerController: bannerController,
        loadingController: loadingController,
        presentingScreen: self,
        session: session,
        sharedDataController: sharedDataController,
        appLaunchController: appLaunchController
    )

    private lazy var cardsFlowCoordinator = CardsFlowCoordinator(presentingScreen: self)
    private lazy var stakingFlowCoordinator = StakingFlowCoordinator(presentingScreen: self)
    private lazy var transitionToBuySellOptions = BottomSheetTransition(presentingViewController: self)

    private var isTransactionOptionsVisible: Bool = false
    private var currentTransactionOptionsAnimator: UIViewPropertyAnimator?

    /// <todo>
    /// Normally, we shouldn't retain data store or create flow coordinator here but our currenct
    /// routing approach hasn't been refactored yet.
    private let swapDataStore: SwapDataStore
    private let analytics: ALGAnalytics
    private let api: ALGAPI
    private let bannerController: BannerController
    private let loadingController: LoadingController
    private let session: Session
    private let sharedDataController: SharedDataController
    private let appLaunchController: AppLaunchController
    private let featureFlagService: FeatureFlagServicing

    init(
        swapDataStore: SwapDataStore,
        analytics: ALGAnalytics,
        api: ALGAPI,
        bannerController: BannerController,
        loadingController: LoadingController,
        session: Session,
        sharedDataController: SharedDataController,
        appLaunchController: AppLaunchController,
        featureFlagService: FeatureFlagServicing
    ) {
        self.swapDataStore = swapDataStore
        self.analytics = analytics
        self.api = api
        self.bannerController = bannerController
        self.loadingController = loadingController
        self.session = session
        self.sharedDataController = sharedDataController
        self.appLaunchController = appLaunchController
        self.featureFlagService = featureFlagService
        super.init()
    }

    override func addTabBar() {
        super.addTabBar()

        tabBar.customizeAppearance(
            [
                .backgroundColor(Colors.Defaults.background)
            ]
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViewAppearance([.backgroundColor(Colors.Defaults.background)])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
        UIApplication.shared.appConfiguration?.session.isValid = true
    }

    override func setListeners() {
        super.setListeners()

        self.observeNetworkChanges()
        observeWhenUserIsOnboardedToSwap()
    }
    
    override func selectedIndexDidChange() {
        switch selectedTab {
        case .home:
            analytics.track(.tabBarPressed(type: .tapHome))
        case .discover:
            analytics.track(.tabBarPressed(type: .tapDiscover))
        case .swap:
            analytics.track(.tabBarPressed(type: .tapSwap))
        case .menu:
            analytics.track(.tabBarPressed(type: .tapMenu))
        case .stake:
            analytics.track(.tabBarPressed(type: .tapStake))
        default:
            break
        }
    }
}

extension TabBarController {
    private func navigateToStakingFlow() {
        stakingFlowCoordinator.launch()
        
        analytics.track(.tapInQuickAction(type: .tapStake))
    }
    
    private func navigateToSwapAssetFlow() {
        swapAssetFlowCoordinator.resetDraft()
        swapAssetFlowCoordinator.launch()

        analytics.track(.tapInQuickAction(type: .tapSwap))
    }

    private func navigateToSendTransaction() {
        sendTransactionFlowCoordinator.launch()

        analytics.track(.tapSendTab())
    }

    private func navigateToReceiveTransaction() {
        receiveTransactionFlowCoordinator.launch()

        analytics.track(.tapReceiveTab())
    }

    private func navigateToBuySell() {

        let eventHandler: BuySellOptionsScreen.EventHandler = {
            [unowned self] event in
            switch event {
            case .performBuyWithMeld:
                self.dismiss(animated: true) {
                    [weak self] in
                    guard let self else { return }
                    self.openBuyWithMeld()
                }
            case .performBuyGiftCardsWithBidali:
                self.dismiss(animated: true) {
                    [weak self] in
                    guard let self else { return }
                    self.openBuyGiftCardsWithBidali()
                }
            }
        }

        transitionToBuySellOptions.perform(
            .buySellOptions(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )
    }

    private func openBuyWithMeld() {
        meldFlowCoordinator.launch()
    }

    private func openBuyGiftCardsWithBidali() {
        bidaliFlowCoordinator.launch()
    }

    private func navigateToQRScanner() {
        scanQRFlowCoordinator.launch()
    }

    private func navigateToBrowseDApps() {
        launchDiscover(with: .browser)
        
        analytics.track(.tapInQuickAction(type: .tapBrowseDApps))
    }

    private func navigateToCardsScreen() {
        cardsFlowCoordinator.launch()
    }
    
    private func launchDiscoverWithBrowserTab() {
        selectedTab = .discover

        let container = selectedScreen as? NavigationContainer
        let screen = container?.viewControllers.first as? DiscoverHomeScreen
        screen?.destination = .browser
    }
}

extension TabBarController {
    private func observeWhenUserIsOnboardedToSwap() {
        observe(notification: SwapDisplayStore.isOnboardedToSwapNotification) {
            [weak self] _ in
            guard let self = self else { return }

            self.updateSwapAction()
        }
    }

    private func updateSwapAction() {
        swapActionViewModel = createSwapActionViewModel()
        swapAction = createSwapListAction()
    }

    private func createStakingActionViewModel() -> StakingTransactionOptionListItemButtonViewModel {
        StakingTransactionOptionListItemButtonViewModel(isBadgeVisible: false)
    }
    
    private func createStakingListAction() -> TransactionOptionListAction {
        return TransactionOptionListAction(
            viewModel: stakingActionViewModel
        ) {
            [weak self] actionView in
            guard let self = self else { return }
            
            actionView.bindData(self.stakingActionViewModel)
            self.navigateToStakingFlow()
        }
    }

    private func createSwapActionViewModel() -> SwapTransactionOptionListItemButtonViewModel {
        let swapDisplayStore = SwapDisplayStore()
        let isOnboardedToSwap = swapDisplayStore.isOnboardedToSwap
        return SwapTransactionOptionListItemButtonViewModel(isBadgeVisible: !isOnboardedToSwap)
    }

    private func createSwapListAction() -> TransactionOptionListAction {
        return TransactionOptionListAction(
            viewModel: swapActionViewModel
        ) {
            [weak self] actionView in
            guard let self = self else { return }

            let swapDisplayStore = SwapDisplayStore()
            let isOnboardedToSwap = swapDisplayStore.isOnboardedToSwap

            self.swapActionViewModel.bindIsBadgeVisible(!isOnboardedToSwap)
            actionView.bindData(self.swapActionViewModel)

            self.navigateToSwapAssetFlow()
        }
    }
}

extension TabBarController {
    private func observeNetworkChanges() {
        observe(notification: NodeSettingsViewController.didUpdateNetwork) {
            [unowned self] _ in
            setNeedsDiscoverTabBarItemUpdateIfNeeded()
            updateBrowseDAppsActionIfNeeded()
        }
    }

    /// <note>
    /// In staging app, the discover tab is always enabled, but in store app, it is enabled only
    /// on mainnet.
    private var isDiscoverEnabled: Bool {
        return !ALGAppTarget.current.isProduction || !api.isTestNet
    }

    func setNeedsDiscoverTabBarItemUpdateIfNeeded() {
        setTabBarItemEnabled(
            isDiscoverEnabled,
            forItemID: .discover
        )
    }

    private func updateBrowseDAppsActionIfNeeded() {
        if browseDAppsAction.isEnabled == isDiscoverEnabled {
            return
        }

        browseDAppsAction = createBrowseDAppsListAction()
    }

    private func createBrowseDAppsListAction() -> TransactionOptionListAction {
        return TransactionOptionListAction(
            isEnabled: isDiscoverEnabled,
            viewModel: BrowseDAppsTransactionOptionListItemButtonViewModel()
        ) {
            [weak self] _ in
            guard let self else { return }
            self.navigateToBrowseDApps()
        }
    }
    
    private func createCardsAction() -> TransactionOptionListAction {
        return TransactionOptionListAction(
            isEnabled: true,
            viewModel: CardsTransactionOptionListItemButtonViewModel()
        ) {
            [weak self] _ in
            guard let self else { return }
            self.navigateToCardsScreen()
        }
    }
    
    private func isCardsFeatureEnabled() -> Bool {
        featureFlagService.isEnabled(.immersiveEnabled) &&
            Environment.current.isCardsFeatureEnabled(for: api.network)
    }
}

extension Array where Element == TabBarItem {
    func index(
        of itemId: TabBarItemID
    ) -> Int? {
        return firstIndex { $0.id == itemId.rawValue }
    }
}

extension TabBarContainer {
    func setTabBarItemEnabled(
        _ isEnabled: Bool,
        forItemID itemID: TabBarItemID
    ) {
        guard let index = items.index(of: itemID) else {
            return
        }

        let barButton = tabBar.barButtons[index]

        if barButton.isEnabled == isEnabled {
            return
        }

        barButton.isEnabled = isEnabled
    }
}

extension TabBarController {
    func launchDiscover(with destination: DiscoverDestination) {
        selectedTab = .discover

        let container = selectedScreen as? NavigationContainer
        let screen = container?.viewControllers.first as? DiscoverHomeScreen
        screen?.destination = destination
    }
}

