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

//   ASADetailViewController.swift

import MacaroonUIKit
import MacaroonUtils
import SnapKit
import UIKit
import Combine
import pera_wallet_core

final class ASADetailViewController: PageContainer {
    
    // MARK: - Data Source
    
    private lazy var navigationTitleView = AccountNameTitleView()
    private lazy var loadingView = makeLoading()
    private lazy var errorView = makeError()
    private lazy var pagesScreen = PageContainer(configuration: configuration, hidePageBar: true)
    
    private lazy var sharedEventHandler: ASADetailViewController.EventHandler = { [weak self] event in
        guard let self else { return }
        switch event {
        case .quickActionsBuy: navigateToBuyAlgoIfPossible()
        case .quickActionsSend: navigateToSendTransactionIfPossible()
        case .quickActionsReceive: navigateToReceiveTransaction()
        case .quickActionsSwap: navigateToSwapAssetIfPossible()
        case let .profileOnPeriodChange(account, asset, newPeriodSelected):
            dataController.updateChartData(
                address: account.address,
                assetId: String(asset.id),
                period: newPeriodSelected
            )
        case .profileOnFavoriteTap: dataController.toogleFavoriteStatus()
        case .profileOnNotificationTap: dataController.tooglePriceAlertStatus()
        }
    }
    
    private lazy var holdingsFragmentScreen = ASAHoldingsFragment(
        account: dataController.account,
        asset: dataController.asset,
        dataController: dataController,
        copyToClipboardController: copyToClipboardController,
        configuration: configuration,
        eventHandler: sharedEventHandler)
    
    private lazy var marketsFragmentScreen = ASAMarketsFragment(
        account: dataController.account,
        asset: dataController.asset,
        currency: sharedDataController.currency,
        copyToClipboardController: copyToClipboardController,
        configuration: configuration,
        eventHandler: sharedEventHandler)

    private lazy var meldFlowCoordinator = MeldFlowCoordinator(
        analytics: analytics,
        presentingScreen: self
    )
    private lazy var swapAssetFlowCoordinator = SwapAssetFlowCoordinator(
        draft: SwapAssetFlowDraft(
            account: dataController.account,
            assetInID: dataController.asset.id
        ),
        dataStore: swapDataStore,
        configuration: configuration,
        presentingScreen: self
    )
    private lazy var sendTransactionFlowCoordinator = SendTransactionFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController,
        account: dataController.account,
        asset: dataController.asset
    )
    private lazy var receiveTransactionFlowCoordinator =
        ReceiveTransactionFlowCoordinator(presentingScreen: self)
    private lazy var undoRekeyFlowCoordinator = UndoRekeyFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController
    )
    private lazy var rekeyToStandardAccountFlowCoordinator = RekeyToStandardAccountFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController
    )
    private lazy var rekeyToLedgerAccountFlowCoordinator = RekeyToLedgerAccountFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController
    )
    private lazy var accountInformationFlowCoordinator = AccountInformationFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController
    )

    private lazy var rekeyingValidator = RekeyingValidator(
        session: session!,
        sharedDataController: sharedDataController
    )

    private var isViewLayoutLoaded = false
    private var selectedPageIndex = 0

    private var shouldDisplayMarketInfo: Bool {
        dataController.asset.isAvailableOnDiscover
    }

    /// <todo>
    /// Normally, we shouldn't retain data store or create flow coordinator here but our currenct
    /// routing approach hasn't been refactored yet.
    private let swapDataStore: SwapDataStore
    private let dataController: ASADetailScreenDataController
    private let copyToClipboardController: CopyToClipboardController
    
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    private let theme = ASADetailViewControllerTheme()
    
    private var cancellables = Set<AnyCancellable>()

    init(
        swapDataStore: SwapDataStore,
        dataController: ASADetailScreenDataController,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.swapDataStore = swapDataStore
        self.dataController = dataController
        self.copyToClipboardController = copyToClipboardController

        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addNavigationTitle()
        addNavigationActions()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = [
            HoldingsPageBarItem(screen: holdingsFragmentScreen),
            MarketsPageBarItem(screen: marketsFragmentScreen)
        ]

        loadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.isEmpty { return }

        if !isViewLayoutLoaded {
            isViewLayoutLoaded = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switchToHighlightedNavigationBarAppearance()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if presentedViewController == nil {
            switchToDefaultNavigationBarAppearance()
        }
    }
}

extension ASADetailViewController {
    func optionsViewControllerDidUndoRekey(_ optionsViewController: OptionsViewController) {
        let sourceAccount = dataController.account
        undoRekeyFlowCoordinator.launch(sourceAccount)
    }
    
    func optionsViewControllerDidOpenRekeyingToLedger(_ optionsViewController: OptionsViewController) {
        let sourceAccount = dataController.account
        rekeyToLedgerAccountFlowCoordinator.launch(sourceAccount)
    }
    
    func optionsViewControllerDidOpenRekeyingToStandardAccount(_ optionsViewController: OptionsViewController) {
        let sourceAccount = dataController.account
        rekeyToStandardAccountFlowCoordinator.launch(sourceAccount)
    }
}

extension ASADetailViewController {
    private func addNavigationTitle() {
        navigationTitleView.customize(theme.navigationTitle)

        navigationItem.titleView = navigationTitleView

        let recognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(copyAccountAddress(_:))
        )
        navigationTitleView.addGestureRecognizer(recognizer)

        bindNavigationTitle()
    }

    private func bindNavigationTitle() {
        let account = dataController.account
        let viewModel = AccountNameTitleViewModel(account)
        navigationTitleView.bindData(viewModel)
    }

    private func addNavigationActions() {
        var rightBarButtonItems: [ALGBarButtonItem] = []

        if dataController.configuration.shouldDisplayAccountActionsBarButtonItem {
            let accountActionsBarButtonItem = makeAccountActionsBarButtonItem()
            rightBarButtonItems.append(accountActionsBarButtonItem)
        }

        if rightBarButtonItems.isEmpty {
            let flexibleSpaceItem = ALGBarButtonItem.flexibleSpace()
            rightBarButtonItems.append(flexibleSpaceItem)
        }

        self.rightBarButtonItems = rightBarButtonItems
    }

    private func makeAccountActionsBarButtonItem() ->  ALGBarButtonItem {
        let account = dataController.account
        let accountActionsItem = ALGBarButtonItem(kind: .account(account)) {
            [unowned self] in
            openAccountInformationScreen()
        }

        return accountActionsItem
    }

    private func openAccountInformationScreen() {
        let sourceAccount = dataController.account
        accountInformationFlowCoordinator.launch(sourceAccount)
    }

    private func updateUIWhenAccountDidRename() {
        bindNavigationTitle()
    }

    private func updateUIWhenDataWillLoad() {
        addLoading()
        removeError()
    }

    private func updateUIWhenDataDidLoad() {
        bindMarketPageData()
        bindHoldingsPageData()
        removeLoading()
        removeError()
    }

    private func updateUIWhenDataDidFailToLoad(_ error: ASADetailScreenDataController.Error) {
        addError()
        removeLoading()
    }

    private func makeLoading() -> ASADetailViewControllerLoadingView {
        let loadingView = ASADetailViewControllerLoadingView()
        loadingView.customize(theme.loading)
        return loadingView
    }

    private func addLoading() {
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        loadingView.startAnimating()
    }

    private func removeLoading() {
        loadingView.removeFromSuperview()
        loadingView.stopAnimating()
    }

    private func makeError() -> NoContentWithActionView {
        let errorView = NoContentWithActionView()
        errorView.customizeAppearance(theme.errorBackground)
        errorView.customize(theme.error)
        return errorView
    }

    private func addError() {
        view.addSubview(errorView)
        errorView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        errorView.startObserving(event: .performPrimaryAction) {
            [weak self] in
            guard let self = self else { return }

            self.dataController.loadData()
        }

        errorView.bindData(ListErrorViewModel())
    }

    private func removeError() {
        errorView.removeFromSuperview()
    }

    private func bindMarketPageData(chartData: ChartViewData? = nil) {
        let asset = dataController.asset
        
        // Get the markets screen from the page container (second screen)
        if let marketScreen = items.last?.screen as? ASAMarketsFragment {
            marketScreen.bindData(asset: asset, account: dataController.account, chartData: chartData)
        }
    }
    
    private func bindHoldingsPageData() {
        let asset = dataController.asset
        if let holdingsScreen = items.first?.screen as? ASAHoldingsFragment {
            holdingsScreen.updateHeader(
                with: dataController.chartViewData ?? ChartViewData(period: .oneWeek, chartValues: [], isLoading: false),
                newAsset: asset,
                shouldDisplayQuickActions: dataController.configuration.shouldDisplayQuickActions,
                eventHandler: sharedEventHandler)
            
            holdingsScreen.updateFavoriteAndNotificationButtons(isAssetPriceAlertEnabled: dataController.asset.isPriceAlertEnabled ?? false, isAssetFavorited: dataController.asset.isFavorited ?? false)
        }
    }
}

extension ASADetailViewController {
    @objc
    private func copyAccountAddress(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            copyToClipboardController.copyAddress(dataController.account)
        }
    }
}

extension ASADetailViewController {
    private func loadData() {
        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .willLoadData: updateUIWhenDataWillLoad()
            case .didLoadData: updateUIWhenDataDidLoad()
            case .didFailToLoadData(let error): updateUIWhenDataDidFailToLoad(error)
            case .didUpdateAccount(let old): updateNavigationItemsIfNeededWhenAccountDidUpdate(old: old)
            case let .didFetchChartData(chartData, errorDescription, period):
                let validChartData = chartData ?? ChartViewData(period: period, chartValues: [], isLoading: false)
                if chartData == nil {
                    bannerController?.presentErrorBanner(
                        title: String(localized: "pass-phrase-verify-sdk-error"),
                        message: errorDescription ?? ""
                    )
                }
                if let holdingsScreen = items.first?.screen as? ASAHoldingsFragment {
                    holdingsScreen.updateChart(with: validChartData)
                }
            case let .didFetchPriceChartData(chartData, _, _): bindMarketPageData(chartData: chartData)
            case let .didUpdateAssetStatus(favorite, priceAlert):
                if let holdingsScreen = items.first?.screen as? ASAHoldingsFragment {
                    holdingsScreen.updateFavoriteAndNotificationButtons(isAssetPriceAlertEnabled: priceAlert, isAssetFavorited: favorite)
                }
                if let marketsScreen = items.last?.screen as? ASAMarketsFragment {
                    marketsScreen.updateFavoriteAndNotificationButtons(isAssetPriceAlertEnabled: priceAlert, isAssetFavorited: favorite)
                }
            case let .didFailToToogleStatus(errorDescription):
                bannerController?.presentErrorBanner(
                    title: String(localized: "pass-phrase-verify-sdk-error"),
                    message: errorDescription
                )
                
            }
        }
        dataController.loadData()
        dataController.fetchInitialChartData(address: dataController.account.address, assetId: String(dataController.asset.id), period: .oneWeek)
        dataController.fetchInitialAssetPriceChartData(assetId: dataController.asset.id, period: .oneWeek)
    }
}

extension ASADetailViewController {
    private func updateNavigationItemsIfNeededWhenAccountDidUpdate(old: Account) {
        if old.authorization == dataController.account.authorization {
            return
        }

        addNavigationActions()
        bindNavigationTitle()
        setNeedsRightBarButtonItemsUpdate()
    }
}

extension ASADetailViewController {
    private func navigateToBuyAlgoIfPossible() {
        let account = dataController.account
        if account.authorization.isNoAuth {
            presentActionsNotAvailableForAccountBanner()
            return
        }

        meldFlowCoordinator.launch(account)
    }

    private func navigateToSwapAssetIfPossible() {
        guard let rootViewController = UIApplication.shared.rootViewController() else { return }
        let account = dataController.account
        if account.authorization.isNoAuth {
            presentActionsNotAvailableForAccountBanner()
            return
        }

        analytics.track(.tapSwapInAlgoDetail())
        rootViewController.launch(tab: .swap, with: SwapAssetFlowDraft(account: account, assetInID: dataController.asset.id))
    }

    private func navigateToSendTransactionIfPossible() {
        let account = dataController.account
        if account.authorization.isNoAuth {
            presentActionsNotAvailableForAccountBanner()
            return
        }

        sendTransactionFlowCoordinator.launch()
        analytics.track(.tapSendInDetail(account: dataController.account))
    }

    private func navigateToReceiveTransaction() {
        receiveTransactionFlowCoordinator.launch(dataController.account)
        analytics.track(.tapReceiveAssetInDetail(account: dataController.account))
    }
}

extension ASADetailViewController {
    private func presentActionsNotAvailableForAccountBanner() {
        bannerController?.presentErrorBanner(
            title: String(localized: "action-not-available-for-account-type"),
            message: ""
        )
    }
}

extension ASADetailViewController {
    enum Event {
        case profileOnNotificationTap
        case profileOnFavoriteTap
        case profileOnPeriodChange(account: Account, asset: Asset, newPeriodSelected: ChartDataPeriod)
        case quickActionsBuy
        case quickActionsSwap
        case quickActionsSend
        case quickActionsReceive
    }
}
