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
//   HomeViewController.swift

import UIKit
import MacaroonUIKit
import MacaroonUtils
import Combine
import pera_wallet_core

final class HomeViewController:
    BaseViewController,
    NotificationObserver,
    UICollectionViewDelegateFlowLayout {
    var notificationObservations: [NSObjectProtocol] = []

    private lazy var transitionToPassphraseDisplay = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToInvalidAccount = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToPortfolioCalculationInfo = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToBuySellOptions = BottomSheetTransition(presentingViewController: self)

    private lazy var alertPresenter = AlertPresenter(
        presentingScreen: self,
        session: session!,
        sharedDataController: sharedDataController,
        items: alertItems
    )

    private lazy var navigationView = HomePortfolioNavigationView()

    private lazy var pushNotificationController = PushNotificationController(
        target: target,
        session: session!,
        api: api!
    )

    private lazy var backupAccountFlowCoordinator = BackUpAccountFlowCoordinator(
        presentingScreen: self,
        api: api!
    )
    private lazy var removeAccountFlowCoordinator = RemoveAccountFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController,
        bannerController: bannerController!
    )
    private lazy var moonPayFlowCoordinator = MoonPayFlowCoordinator(presentingScreen: self)
    private lazy var meldFlowCoordinator = MeldFlowCoordinator(
        analytics: analytics,
        presentingScreen: self
    )
    private lazy var bidaliFlowCoordinator = BidaliFlowCoordinator(presentingScreen: self, api: api!)

    private lazy var swapAssetFlowCoordinator = SwapAssetFlowCoordinator(
        draft: SwapAssetFlowDraft(),
        dataStore: swapDataStore,
        configuration: configuration,
        presentingScreen: self
    )
    private lazy var sendTransactionFlowCoordinator = SendTransactionFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController
    )
    private lazy var receiveTransactionFlowCoordinator = ReceiveTransactionFlowCoordinator(presentingScreen: self)
    private lazy var scanQRFlowCoordinator = ScanQRFlowCoordinator(
        analytics: analytics,
        api: api!,
        bannerController: bannerController!,
        loadingController: loadingController!,
        presentingScreen: self,
        session: session!,
        sharedDataController: sharedDataController,
        appLaunchController: configuration.launchController,
        hdWalletStorage: configuration.hdWalletStorage
    )
    private lazy var algorandSecureBackupFlowCoordinator = AlgorandSecureBackupFlowCoordinator(
        configuration: configuration,
        presentingScreen: self
    )
    private lazy var stakingFlowCoordinator = StakingFlowCoordinator(presentingScreen: self)

    private let copyToClipboardController: CopyToClipboardController

    private let onceWhenViewDidAppear = Once()

    override var analyticsScreen: ALGAnalyticsScreen? {
        return .init(name: .accountList)
    }

    private lazy var listView =
        UICollectionView(frame: .zero, collectionViewLayout: HomeListLayout.build())
    private lazy var listBackgroundView = UIView()

    private lazy var listLayout = HomeListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = HomeListDataSource(listView, shouldShowFundButton: configuration.featureFlagService.isEnabled(.xoSwapEnabled))

    /// <todo>: Refactor
    /// This is needed for ChoosePasswordViewControllerDelegate's method.
    private var selectedAccountHandle: AccountHandle? = nil
    private var sendTransactionDraft: SendTransactionDraft?
    
    private var totalPortfolioValue: PortfolioValue?

    /// <todo>
    /// Normally, we shouldn't retain data store or create flow coordinator here but our currenct
    /// routing approach hasn't been refactored yet.
    private let swapDataStore: SwapDataStore
    private let dataController: HomeDataController

    private var incomingASAsRequestList: IncomingASAsRequestList?
    private var listWasScrolled = false
    
    @Published private var isPrivacyModeTooltipVisible: Bool = false
    private var portfolioTooltipCancellable: AnyCancellable?
    
    init(
        swapDataStore: SwapDataStore,
        dataController: HomeDataController,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.swapDataStore = swapDataStore
        self.dataController = dataController
        self.copyToClipboardController = copyToClipboardController

        super.init(configuration: configuration)
    }

    deinit {
        stopObservingNotifications()
    }

    override func configureNavigationBarAppearance() {
        configureNotificationBarButton()
        configureASARequestBarButton()
        navigationView.prepareLayout(NoLayoutSheet())

        navigationItem.titleView = navigationView
    }

    override func customizeTabBarAppearence() {
        tabBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
        
        dataController.eventHandler = {
            [weak self] event in
            guard let self else { return }
            
            switch event {
            case .didUpdate(let updates):
                let totalPortfolioItem = updates.totalPortfolioItem

                self.totalPortfolioValue = totalPortfolioItem?.portfolioValue

                self.bindNavigation(totalPortfolioItem)

                self.listDataSource.apply(
                    updates.snapshot,
                    animatingDifferences: true
                )

                if totalPortfolioItem != nil {
                    self.alertPresenter.presentIfNeeded()
                }
            case .deliverASARequestsContentUpdate(let asasReqUpdate):
                self.sharedDataController.currentInboxRequestCount = asasReqUpdate?.results.map({$0.requestCount ?? 0}).reduce(0, +) ?? 0
                self.incomingASAsRequestList = asasReqUpdate
                if self.sharedDataController.currentInboxRequestCount == 0 {
                    self.leftBarButtonItems = []
                    self.setNeedsNavigationBarAppearanceUpdate()
                }
                if !listWasScrolled {
                    self.configureASARequestBarButton()
                }
            case .didUpdateSpotBanner(let errorDescription):
                guard let errorDescription else {
                    dataController.fetchSpotBanners()
                    return
                }
                self.bannerController?.presentErrorBanner(
                    title: String(localized: "pass-phrase-verify-sdk-error"),
                    message: errorDescription
                )
            case .didFailWithError(let errorDescription):
                guard let errorDescription else {
                    return
                }
                self.bannerController?.presentErrorBanner(
                    title: String(localized: "pass-phrase-verify-sdk-error"),
                    message: errorDescription
                )
            case .shouldReloadPortfolio(let chartSelectedPointViewModel, let totalPortfolioItem, let tendenciesVM):
                guard let totalPortfolioItem else {
                    return
                }
                let isAmountHidden = ObservableUserDefaults.shared.isPrivacyModeEnabled
                let homePortfolioViewModel = HomePortfolioViewModel(
                    totalPortfolioItem,
                    selectedPoint: chartSelectedPointViewModel,
                    tendenciesVM: isAmountHidden ? nil : tendenciesVM
                )
                self.listDataSource.reloadPortfolio(with: homePortfolioViewModel)
            }
        }
        
        dataController.load()

        pushNotificationController.requestAuthorization()
        pushNotificationController.sendDeviceDetails()

        requestAppReview()
        setupGestures()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !listView.frame.isEmpty {
            updateUIWhenViewDidLayoutSubviews()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAnimatingLoadingIfNeededWhenViewWillAppear()
        switchToHighlightedNavigationBarAppearance()
        configureNavigationBarAppearance()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isViewFirstAppeared {
            presentPasscodeFlowIfNeeded()
        }
        
        if PeraUserDefaults.wasPrivacyTooltipPresented != true {
            PeraUserDefaults.wasPrivacyTooltipPresented = true
            isPrivacyModeTooltipVisible = true
        }
        
        dataController.fetchAnnouncements()
        dataController.fetchSpotBanners()
        dataController.fetchInitialChartData(period: .oneWeek)
        dataController.fetchUSDCDefaultAsset()
        dataController.fetchIncomingASAsRequests()
        lastSeenNotificationController?.checkStatus()
        showNewAccountAnimationIfNeeded()
    }

    override func viewWillDisappear(
        _ animated: Bool
    ) {
        super.viewWillDisappear(animated)

        if presentedViewController == nil {
            switchToDefaultNavigationBarAppearance()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAnimatingLoadingIfNeededWhenViewDidDisappear()
    }

    override func linkInteractors() {
        super.linkInteractors()

        observe(notification: .newNotificationReceieved) {
            [weak self] _ in
            guard let self = self else {
                return
            }

            self.configureNewNotificationBarButton()
        }
    }
    
    @MainActor
    private func showNewAccountAnimationIfNeeded() {
        guard PeraUserDefaults.shouldShowNewAccountAnimation ?? false else { return }
        Task { [weak self] in
            guard let self else { return }
            PeraUserDefaults.shouldShowNewAccountAnimation = false
            await playConfettiAnimation()
        }
    }
    
    @MainActor
    private func playConfettiAnimation() async {
        view.layoutIfNeeded()

        let animationView = LottieImageView()
        animationView.contentMode = .scaleAspectFill
        animationView.isUserInteractionEnabled = false
        animationView.setAnimation("pera-confetti")

        view.addSubview(animationView)
        animationView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(500)
        }

        defer { animationView.removeFromSuperview() }

        var config = LottieImageView.Configuration()
        config.loopMode = .playOnce
        _ = await animationView.play(with: config)
    }
    
    // MARK: - Setups
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapAnywhere))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Handlers
    
    @objc private func handleOnTapAnywhere() {
        isPrivacyModeTooltipVisible = false
    }
}

extension HomeViewController {
    private func startAnimatingLoadingIfNeededWhenViewWillAppear() {
        if isViewFirstAppeared { return }

        let loadingCell = listView.visibleCells.first { $0 is HomeLoadingCell } as? HomeLoadingCell
        loadingCell?.startAnimating()
    }

    private func stopAnimatingLoadingIfNeededWhenViewDidDisappear() {
        let loadingCell = listView.visibleCells.first { $0 is HomeLoadingCell } as? HomeLoadingCell
        loadingCell?.stopAnimating()
    }
}

extension HomeViewController {
    private func configureNotificationBarButton() {
        let qrScannerBarButtonItem = ALGBarButtonItem(kind: .qr) { [weak self] in
            guard let self else { return }
            
            self.analytics.track(.recordHomeScreen(type: .qrScan))
            self.scanQRFlowCoordinator.launch()
        }
        
        let notificationBarButtonItem = ALGBarButtonItem(kind: .notification) { [weak self] in
            guard let self = self else {
                return
            }
            self.analytics.track(.recordHomeScreen(type: .notification))

            self.open(
                .notifications,
                by: .push
            )
        }

        rightBarButtonItems = [notificationBarButtonItem, qrScannerBarButtonItem]
        setNeedsNavigationBarAppearanceUpdate()
    }

    private func configureNewNotificationBarButton() {
        let qrScannerBarButtonItem = ALGBarButtonItem(kind: .qr) { [weak self] in
            guard let self else { return }
            
            self.analytics.track(.recordHomeScreen(type: .qrScan))
            self.scanQRFlowCoordinator.launch()
        }
        
        let notificationBarButtonItem = ALGBarButtonItem(kind: .newNotification) { [weak self] in
            guard let self = self else {
                return
            }
            self.configureNotificationBarButton()
            self.analytics.track(.recordHomeScreen(type: .notification))
            self.open(.notifications, by: .push)
        }

        rightBarButtonItems = [notificationBarButtonItem, qrScannerBarButtonItem]
        setNeedsNavigationBarAppearanceUpdate()
    }
    
    private func configureASARequestBarButton() {
        let asasRequestsCount = sharedDataController.currentInboxRequestCount
        guard asasRequestsCount > 0 else {
            self.leftBarButtonItems = []
            self.setNeedsNavigationBarAppearanceUpdate()
            return
        }
        
        let notificationBarButtonItem = ALGBarButtonItem(kind: .asaInbox(asasRequestsCount)) { [weak self] in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.analytics.track(.recordHomeScreen(type: .assetInbox))
                self.openASAInbox()
            }
        }

        leftBarButtonItems = [notificationBarButtonItem]
        setNeedsNavigationBarAppearanceUpdate()
    }
}

extension HomeViewController {
    private func addUI() {
        addListBackground()
        addList()
    }

    private func updateUIWhenViewDidLayoutSubviews() {
        updateListBackgroundWhenViewDidLayoutSubviews()
    }

    private func updateUIWhenListDidScroll() {
        updateNavigationBarWhenListDidScroll()
        updateListBackgroundWhenListDidScroll()
    }
    
    private func updateNavigationBarWhenListDidScroll() {
        let visibleIndexPaths = listView.indexPathsForVisibleItems
        let headerVisible = visibleIndexPaths.contains(IndexPath(item: 0, section: 0))
        navigationView.animateTitleVisible(!headerVisible) {
            [weak self] isVisible in
            guard let self else { return }
            
            if isVisible {
                guard self.sharedDataController.currentInboxRequestCount > 0 else {
                    return
                }
                
                let notificationBarButtonItem = ALGBarButtonItem(kind: .asaInbox(0)) { [weak self] in
                    guard let self = self else {
                        return
                    }
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.analytics.track(.recordHomeScreen(type: .assetInbox))
                        self.openASAInbox()
                    }
                }
                self.leftBarButtonItems = [notificationBarButtonItem]
                self.setNeedsNavigationBarAppearanceUpdate()
                self.listWasScrolled = true
            } else {
                self.listWasScrolled = false
                self.configureASARequestBarButton()
            }
        }
    }

    private func addListBackground() {
        listBackgroundView.customizeAppearance(
            [
                .backgroundColor(Colors.Defaults.background)
            ]
        )

        view.addSubview(listBackgroundView)
        listBackgroundView.snp.makeConstraints {
            $0.fitToHeight(0)
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func updateListBackgroundWhenListDidScroll() {
        updateListBackgroundWhenViewDidLayoutSubviews()
    }

    private func updateListBackgroundWhenViewDidLayoutSubviews() {
        /// <note>
        /// 250 is a number smaller than the total height of the total portfolio and the quick
        /// actions menu cells, and big enough to cover the background area when the system
        /// triggers auto-scrolling to the top because of the applying snapshot (The system just
        /// does it if the user pulls down the list extending the bounds of the content even if
        /// there isn't anything to update.)
        let preferredHeight = 250 - listView.contentOffset.y

        listBackgroundView.snp.updateConstraints {
            $0.fitToHeight(max(preferredHeight, 0))
        }
    }

    private func setListBackgroundVisible(
        _ isVisible: Bool
    ) {
        let isHidden = !isVisible

        if listBackgroundView.isHidden == isHidden {
            return
        }

        listBackgroundView.isHidden = isHidden

        if !isHidden {
            updateListBackgroundWhenViewDidLayoutSubviews()
        }
    }

    private func addList() {
        listView.customizeAppearance(
            [
                .backgroundColor(UIColor.clear)
            ]
        )

        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        listView.showsVerticalScrollIndicator = false
        listView.showsHorizontalScrollIndicator = false
        listView.alwaysBounceVertical = true
        listView.delegate = self
    }
}

extension HomeViewController {
    private func bindNavigation(
        _ totalPortfolioItem: TotalPortfolioItem?
    ) {
        let viewModel = HomePortfolioNavigationViewModel(totalPortfolioItem)
        navigationView.bind(viewModel)
    }
}

extension HomeViewController {
    private func linkInteractors(
        _ cell: NoContentWithActionCell
    ) {
        cell.startObserving(event: .performPrimaryAction) {
            AppDelegate.shared?.launchOnboarding()
        }
    }
    
    private func linkInteractors(
        _ cell: HomePortfolioCell,
        for item: HomePortfolioViewModel
    ) {
        cell.startObserving(event: .showInfo) {
            [weak self] in
            guard let self else { return }
            
            /// <todo>
            /// How to manage it without knowing view controller. Name conventions vs. protocols???
            let eventHandler: PortfolioCalculationInfoViewController.EventHandler = {
                [weak self] event in
                guard let self else { return }

                switch event {
                case .close:
                    self.dismiss(animated: true)
                }
            }

            self.transitionToPortfolioCalculationInfo.perform(
                .portfolioCalculationInfo(
                    result: self.totalPortfolioValue,
                    eventHandler: eventHandler
                ),
                by: .presentWithoutNavigationController
            )
        }
        
        cell.startObserving(event: .onAmountTap) {
            ObservableUserDefaults.shared.isPrivacyModeEnabled.toggle()
        }
        
        portfolioTooltipCancellable?.cancel()
        portfolioTooltipCancellable = $isPrivacyModeTooltipVisible
            .receive(on: DispatchQueue.main)
            .sink { [weak cell] in cell?.isPrivacyModeTooltipVisible = $0 }
    }

    private func linkInteractors(
        _ cell: HomeQuickActionsCell
    ) {
        cell.startObserving(event: .swap) {
            [weak self] in
            guard let self, let rootViewController = UIApplication.shared.rootViewController() else { return }
            analytics.track(.recordHomeScreen(type: .swap))
            rootViewController.launch(tab: .swap)
        }
        
        cell.startObserving(event: .buy) {
            [weak self] in
            guard let self else { return }
            analytics.track(.recordHomeScreen(type: .buyAlgo))
            openBuySellOptions()
        }
        
        cell.startObserving(event: .stake) {
            [weak self] in
            guard let self else { return }
            analytics.track(.recordHomeScreen(type: .stake))
            open(.staking, by: .push)
        }
        
        cell.startObserving(event: .fund) {
            [weak self] in
            guard let self, let rootViewController = UIApplication.shared.rootViewController() else { return }
            analytics.track(.recordHomeScreen(type: .fund))
            rootViewController.launch(tab: .fund)
        }

        cell.startObserving(event: .send) {
            [weak self] in
            guard let self else { return }
            analytics.track(.recordHomeScreen(type: .send))
            sendTransactionFlowCoordinator.launch()
        }
    }
    
    private func linkInteractors(
        _ cell: HomeChartsCell
    ) {
        cell.onPeriodChange = { [weak self] newPeriodSelected in
            guard let self else { return }
            dataController.updateChartData(period: newPeriodSelected)
        }
        cell.onPointSelected = { [weak self] pointSelected in
            guard let self else { return }
            dataController.updatePortfolio(with: pointSelected)
            analytics.track(.recordHomeScreen(type: .tapChart))
        }
    }

    private func linkInteractors(
        _ cell: GenericAnnouncementCell,
        for item: AnnouncementViewModel
    ) {
        cell.startObserving(event: .close) {
            [weak self] in
            guard let self else { return }

            self.dataController.hideAnnouncement()
        }

        cell.startObserving(event: .action) {
            [weak self] in
            guard let self, let ctaUrl = item.ctaUrl else { return }
            self.triggerBannerCTA(itemUrl: ctaUrl)
            
            self.analytics.track(.recordHomeScreen(type: .visitGeneric))
        }
    }

    private func linkInteractors(
        _ cell: StakingAnnouncementCell,
        for item: AnnouncementViewModel
    ) {
        cell.startObserving(event: .close) {
            [weak self] in
            guard let self else { return }

            self.dataController.hideAnnouncement()
        }

        cell.startObserving(event: .action) {
            [weak self] in
            guard let self, let ctaUrl = item.ctaUrl else { return }
            self.triggerBannerCTA(itemUrl: ctaUrl)
            
            self.analytics.track(.recordHomeScreen(type: .visitStaking))
        }
    }
    
    private func linkInteractors(
        _ cell: CardAnnouncementCell,
        for item: AnnouncementViewModel
    ) {
        cell.startObserving(event: .close) {
            [weak self] in
            guard let self else { return }

            self.dataController.hideAnnouncement()
        }

        cell.startObserving(event: .action) {
            [weak self] in
            guard let self, let ctaUrl = item.ctaUrl else { return }
            self.triggerBannerCTA(itemUrl: ctaUrl)
            
            self.analytics.track(.recordHomeScreen(type: .visitCard))
        }
    }
    
    private func linkInteractors(
        _ cell: RetailCampaignAnnouncementCell,
        for item: AnnouncementViewModel
    ) {
        cell.startObserving(event: .close) {
            [weak self] in
            guard let self else { return }

            self.dataController.hideAnnouncement()
        }

        cell.startObserving(event: .action) {
            [weak self] in
            guard let self, let ctaUrl = item.ctaUrl else { return }
            self.triggerBannerCTA(itemUrl: ctaUrl)
            
            self.analytics.track(.recordHomeScreen(type: .visitRetail))
        }
    }

    private func linkInteractors(
        _ cell: GovernanceAnnouncementCell,
        for item: AnnouncementViewModel
    ) {
        cell.startObserving(event: .close) {
            [weak self] in
            guard let self else { return }

            self.dataController.hideAnnouncement()
        }

        cell.startObserving(event: .action) {
            [weak self] in
            guard let self, let ctaUrl = item.ctaUrl else { return }
            self.triggerBannerCTA(itemUrl: ctaUrl)

            self.analytics.track(.recordHomeScreen(type: .visitGovernance))
        }
    }

    private func linkBackupInteractors(
        _ cell: GenericAnnouncementCell,
        for item: AnnouncementViewModel
    ) {
        cell.startObserving(event: .close) {
            [weak self] in
            guard let self else { return }

            self.dataController.hideAnnouncement()
        }

        cell.startObserving(event: .action) {
            [weak self] in
            guard let self else { return }

            self.algorandSecureBackupFlowCoordinator.launch()
        }
    }
    
    private func linkInteractors(
        _ cell: HomeAccountsHeader,
        for item: ManagementItemViewModel
    ) {
        cell.startObserving(event: .primaryAction) {
            let eventHandler: SortAccountListViewController.EventHandler = {
                [weak self] event in
                guard let self else { return }

                self.dismiss(animated: true) {
                    [weak self] in
                    guard let self else { return }

                    switch event {
                    case .didComplete:
                        self.dataController.reload()
                    }
                }
            }
            
            self.analytics.track(.recordHomeScreen(type: .sort))

            self.open(
                .sortAccountList(
                    dataController: SortAccountListLocalDataController(
                        session: self.session!,
                        sharedDataController: self.sharedDataController
                    ),
                     eventHandler: eventHandler
                ),
                by: .present
            )
        }
        cell.startObserving(event: .secondaryAction) {
            [unowned self] in

            if let authenticatedUser = self.session?.authenticatedUser,
               authenticatedUser.hasReachedTotalAccountLimit {
                self.bannerController?.presentErrorBanner(
                    title: String(localized: "user-account-limit-error-title"),
                    message: String(localized: "user-account-limit-error-message")
                )
                return
            }

            self.analytics.track(.recordHomeScreen(type: .addAccount))
            self.open(
                .addAccount,
                by: .customPresent(
                    presentationStyle: .fullScreen,
                    transitionStyle: nil,
                    transitioningDelegate: nil
                )
            )
        }
    }

    private func triggerBannerCTA(itemUrl: URL) {
        let url = itemUrl.browserDeeplinkURL ?? itemUrl
        
        if let externalDeepLink = url.externalDeepLink {
            launchController.receive(
                deeplinkWithSource: .externalDeepLink(externalDeepLink)
            )
            return
        }

        let inAppBrowser = open(
            .externalInAppBrowser(destination: .url(url)),
            by: .push
        ) as? DiscoverExternalInAppBrowserScreen
        inAppBrowser?.eventHandler = {
            [weak inAppBrowser] event in
            switch event {
            case .goBack:
                inAppBrowser?.popScreen()
            default: break
            }
        }
    }
}

extension HomeViewController {
    private func openBackUpAccount() {
        backupAccountFlowCoordinator.eventHandler = {
            [weak self] event in
            guard let self else { return }

            switch event {
            case .didBackUpAccount:
                self.dataController.reload()
            }
        }

        let notBackedUpAccounts = sharedDataController.accountCollection.filter {
            return !$0.value.isBackedUp
        }
        backupAccountFlowCoordinator.launch(notBackedUpAccounts)
    }
}

extension HomeViewController {
    private func openBuySellOptions() {
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
        analytics.track(.recordHomeScreen(type: .buyAlgo))

        meldFlowCoordinator.launch()
    }
}

extension HomeViewController {
    private func openBuyGiftCardsWithBidali() {
        bidaliFlowCoordinator.launch()
    }
}

extension HomeViewController {
    private func requestAppReview() {
        asyncMain(afterDuration: 1.0) {
            AlgorandAppStoreReviewer().requestReviewIfAppropriate()
        }
    }

    private func presentPasscodeFlowIfNeeded() {
        guard let session = session,
              !session.hasPassword() else {
                  return
              }

        var passcodeSettingDisplayStore = PasscodeSettingDisplayStore()

        if !passcodeSettingDisplayStore.hasPermissionToAskAgain {
            return
        }

        passcodeSettingDisplayStore.increaseAppOpenCount()

        if passcodeSettingDisplayStore.shouldAskForPasscode {
            let controller = open(
                .tutorial(flow: .none, tutorial: .passcode),
                by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
            ) as? TutorialViewController
            controller?.hidesCloseBarButtonItem = true
            controller?.uiHandlers.didTapSecondaryActionButton = { tutorialViewController in
                tutorialViewController.dismissScreen()
            }
            controller?.uiHandlers.didTapDontAskAgain = { tutorialViewController in
                tutorialViewController.dismissScreen()
                passcodeSettingDisplayStore.disableAskingPasscode()
            }
        }
    }
}

extension HomeViewController {
    private func presentOptions(for accountHandle: AccountHandle) {
        transitionToInvalidAccount.perform(
            .invalidAccount(
                account: accountHandle,
                uiInteractionsHandler: linkInvalidAccountOptionsUIInteractions(
                    accountHandle
                )
            )
            ,
            by: .presentWithoutNavigationController
        )
    }
}

extension HomeViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            insetForSectionAt: section
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
    }
}

extension HomeViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch itemIdentifier {
        case .empty(let item):
            switch item {
            case .loading:
                setListBackgroundVisible(true)
                guard let cell = cell as? HomeLoadingCell else { return }
                cell.startAnimating()
            case .noContent:
                setListBackgroundVisible(false)
                guard let cell = cell as? NoContentWithActionCell else { return }
                linkInteractors(cell)
            }
        case .portfolio(let item):
            setListBackgroundVisible(true)

            switch item {
            case .portfolio(let portfolioItem):
                guard let cell = cell as? HomePortfolioCell else { return }
                linkInteractors(
                    cell,
                    for: portfolioItem
                )
            case .quickActions:
                guard let cell = cell as? HomeQuickActionsCell else { return }
                linkInteractors(cell)
            case .charts:
                guard let cell = cell as? HomeChartsCell else { return }
                
                linkInteractors(cell)
            }
        case .announcement(let item):
            switch item.type {
            case .governance:
                guard let cell = cell as? GovernanceAnnouncementCell else { return }
                linkInteractors(cell, for: item)
            case .generic:
                guard let cell = cell as? GenericAnnouncementCell else { return }
                linkInteractors(cell, for: item)
            case .backup:
                guard let cell = cell as? GenericAnnouncementCell else { return }
                linkBackupInteractors(cell, for: item)
            case .staking:
                guard let cell = cell as? StakingAnnouncementCell else { return }
                linkInteractors(cell, for: item)
            case .card:
                guard let cell = cell as? CardAnnouncementCell else { return }
                linkInteractors(cell, for: item)
            case .retail:
                guard let cell = cell as? RetailCampaignAnnouncementCell else { return }
                linkInteractors(cell, for: item)
            }
        case .carouselBanner:
            guard let cell = cell as? CarouselBannerCell else { return }
            cell.delegate = self
        case .account(let item):
            switch item {
            case .header(let headerItem):
                guard let cell = cell as? HomeAccountsHeader else { return }
                linkInteractors(
                    cell,
                    for: headerItem
                )
            default:
                break
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch itemIdentifier {
        case .empty(let item):
            switch item {
            case .loading:
                let loadingCell = cell as? HomeLoadingCell
                loadingCell?.stopAnimating()
            default:
                break
            }
        default:
            break
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let account = getAccount(at: indexPath) else {
            return
        }

        selectedAccountHandle = account

        if !account.isAvailable {
            presentOptions(for: account)
            return
        }

        let eventHandler: AccountDetailViewController.EventHandler = {
            [weak self] event in
            guard let self else { return }

            switch event {
            case .didEdit:
                self.dataController.reload()
            case .didRemove:
                self.navigationController?.popToViewController(
                    self,
                    animated: true
                )
                self.dataController.reload()
            case .didBackUp:
                self.dataController.reload()
            }
        }        
        let requestCount = self.incomingASAsRequestList?.results
            .first { $0.address == account.value.address }?.requestCount ?? 0
        open(
            .accountDetail(accountHandle: account, eventHandler: eventHandler, incomingASAsRequestsCount: requestCount),
            by: .push
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let account = getAccount(at: indexPath)?.value else {
            return nil
        }

        return UIContextMenuConfiguration(
            identifier: indexPath as NSIndexPath
        ) { _ in
            let copyActionItem = UIAction(item: .copyAddress) {
                [unowned self] _ in
                self.copyToClipboardController.copyAddress(account)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard
            let indexPath = configuration.identifier as? IndexPath,
            let cell = collectionView.cellForItem(at: indexPath)
        else {
            return nil
        }

        return UITargetedPreview(
            view: cell,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard
            let indexPath = configuration.identifier as? IndexPath,
            let cell = collectionView.cellForItem(at: indexPath)
        else {
            return nil
        }

        return UITargetedPreview(
            view: cell,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }
}

extension HomeViewController {
    func scrollViewDidScroll(
        _ scrollView: UIScrollView
    ) {
        updateUIWhenListDidScroll()
    }

    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        if !decelerate {
            updateUIWhenListDidScroll()
        }
    }

    func scrollViewDidEndDecelerating(
        _ scrollView: UIScrollView
    ) {
        updateUIWhenListDidScroll()
    }
}

extension HomeViewController: ChoosePasswordViewControllerDelegate {
    func linkInvalidAccountOptionsUIInteractions(_ accountHandle: AccountHandle) -> InvalidAccountOptionsViewController.InvalidAccountOptionsUIInteractions {
        var uiInteractions = InvalidAccountOptionsViewController.InvalidAccountOptionsUIInteractions()

        uiInteractions.didTapShowQRCode = {
            [weak self] in

            guard let self = self else {
                return
            }

            let draft = QRCreationDraft(
                address: accountHandle.value.address,
                mode: .address,
                title: accountHandle.value.name
            )
            self.open(
                .qrGenerator(
                    title: accountHandle.value.primaryDisplayName,
                    draft: draft,
                    isTrackable: true
                ),
                by: .present
            )
        }

        uiInteractions.didTapViewPassphrase = {
            [weak self] in

            guard let self = self else {
                return
            }

            guard let session = self.session else {
                return
            }

            if !session.hasPassword() {
                self.presentPassphraseView(accountHandle)
                return
            }

            let localAuthenticator = LocalAuthenticator(session: session)

            if localAuthenticator.hasAuthentication() {
                do {
                    try localAuthenticator.authenticate()
                    self.presentPassphraseView(accountHandle)
                } catch {
                    self.presentPasswordConfirmScreen()
                }
                return
            }
            self.presentPasswordConfirmScreen()
        }

        uiInteractions.didTapCopyAddress = {
            [weak self] in

            guard let self = self else {
                return
            }

            let account = accountHandle.value

            self.analytics.track(.showQRCopy(account: account))
            self.copyToClipboardController.copyAddress(account)
        }

        uiInteractions.didTapRemoveAccount = {
            [weak self] in
            
            guard let self = self else {
                return
            }

            let account = accountHandle.value
            self.openRemoveAccount(account)
        }

        return uiInteractions
    }

    private func presentPasswordConfirmScreen() {
        let controller = self.open(
            .choosePassword(
                mode: .confirm(flow: .viewPassphrase),
                flow: nil
            ),
            by: .present
        ) as? ChoosePasswordViewController
        controller?.delegate = self
    }

    func choosePasswordViewController(
        _ choosePasswordViewController: ChoosePasswordViewController,
        didConfirmPassword isConfirmed: Bool
    ) {
        guard let selectedAccountHandle else { return }

        choosePasswordViewController.dismissScreen {
            [weak self] in
            guard let self else { return }
            
            if isConfirmed {
                self.presentPassphraseView(selectedAccountHandle)
            }
        }
    }

    private func presentPassphraseView(_ accountHandle: AccountHandle) {
        let eventHandler: PassphraseWarningScreen.EventHandler = {
            [weak self] event in
            guard let self else { return }
            switch event {
            case .close:
                dismiss(animated: true)
            case .reveal:
                dismiss(animated: true) {
                    [weak self] in
                    guard let self else { return }
                    transitionToPassphraseDisplay.perform(
                        .passphraseDisplay(address: accountHandle.value),
                        by: .present
                    )
                }
            }
        }
        
        transitionToPassphraseDisplay.perform(
            .passphraseWarning(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )
    }

    private func openRemoveAccount(_ account: Account) {
        removeAccountFlowCoordinator.eventHandler = {
            [weak self] event in
            guard let self else { return }
            switch event {
            case .didRemoveAccount:
                self.dataController.reload()
            }
        }

        removeAccountFlowCoordinator.launch(account)
    }
}

extension HomeViewController {
    private func getAccount(
        at indexPath: IndexPath
    ) -> AccountHandle? {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        guard case HomeItemIdentifier.account(HomeAccountItemIdentifier.cell(let item)) = itemIdentifier else {
            return nil
        }

        return dataController[item.address]
    }
}

extension HomeViewController: CarouselBannerDelegate {
    func didPressBanner(in banner: CarouselBannerItemModel?) {
        if let banner, banner.isBackupBanner {
            openBackUpAccount()
        } else {
            guard let itemUrl = banner?.url else { return }
            triggerBannerCTA(itemUrl: itemUrl)
        }
        analytics.track(.spotBannerPressed(type: .tapBanner, name: banner?.text ?? .unavailable))
    }
    
    func didTapCloseButton(in banner: CarouselBannerItemModel?) {
        guard let banner else { return }
        dataController.updateClose(for: banner)
        analytics.track(.spotBannerPressed(type: .tapClose, name: banner.text))
    }
}

struct PasscodeSettingDisplayStore: Storable {
    typealias Object = Any

    let appOpenCountToAskPasscode = 5

    private let appOpenCountKey = "com.algorand.algorand.passcode.app.count.key"
    private let dontAskAgainKey = "com.algorand.algorand.passcode.dont.ask.again"

    var appOpenCount: Int {
        return userDefaults.integer(forKey: appOpenCountKey)
    }

    mutating func increaseAppOpenCount() {
        userDefaults.set(appOpenCount + 1, forKey: appOpenCountKey)
    }

    var hasPermissionToAskAgain: Bool {
        return !userDefaults.bool(forKey: dontAskAgainKey)
    }

    mutating func disableAskingPasscode() {
        userDefaults.set(true, forKey: dontAskAgainKey)
    }

    var shouldAskForPasscode: Bool {
        return appOpenCount % appOpenCountToAskPasscode == 0
    }
}

extension HomeViewController {
    /// <note>
    /// Sort by order to be presented.
    private var alertItems: [any AlertItem] {
        [
            makeCopyAddressIntroductionAlertItem(),
            makeSwapIntroductionAlertItem(),
            makeBuyGiftCardsWithCryptoIntroductionAlertItem()
        ]
    }

    private func makeCopyAddressIntroductionAlertItem() -> any AlertItem {
        return CopyAddressIntroductionAlertItem(delegate: self)
    }

    private func makeSwapIntroductionAlertItem() -> any AlertItem {
        return SwapIntroductionAlertItem(delegate: swapAssetFlowCoordinator)
    }

    private func makeBuyGiftCardsWithCryptoIntroductionAlertItem() -> any AlertItem {
        return BuyGiftCardsWithCryptoIntroductionAlertItem(delegate: self)
    }
}

extension HomeViewController: CopyAddressIntroductionAlertItemDelegate {
    func copyAddressIntroductionAlertItemDidPerformGotIt(_ item: CopyAddressIntroductionAlertItem) {
        dismiss(animated: true)
    }
}

extension HomeViewController: BuyGiftCardsWithCryptoIntroductionAlertItemDelegate {
    func buyGiftCardsWithCryptoIntroductionAlertItemDidPerformBuyGiftCardsAction(_ item: BuyGiftCardsWithCryptoIntroductionAlertItem) {
        dismiss(animated: true) {
            [unowned self] in
            self.openBuyGiftCardsWithCrypto()
        }
    }

    private func openBuyGiftCardsWithCrypto() {
        openBuyGiftCardsWithBidali()
    }

    func buyGiftCardsWithCryptoIntroductionAlertItemDidPerformLaterAction(_ item: BuyGiftCardsWithCryptoIntroductionAlertItem) {
        dismiss(animated: true)
    }
}

extension HomeViewController {
    private func openASAInbox() {
        let screen = open(
            .incomingASAAccounts(
                result: incomingASAsRequestList
            ),
            by: .push
        ) as? IncomingASAAccountsViewController
        
        screen?.eventHandler = { [weak screen] event in
            guard let screen else {
                return
            }
                                
            switch event {
            case .didCompleteTransaction:
                screen.closeScreen(by: .pop, animated: false)
            }
        }
    }
}
