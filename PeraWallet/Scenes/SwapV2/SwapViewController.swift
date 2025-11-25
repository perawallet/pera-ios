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

//   SwapViewController.swift

import SwiftUI
import MacaroonUIKit
import pera_wallet_core

final class SwapViewController: BaseViewController {
    
    // MARK: - Properties
    
    var launchDraft: SwapAssetFlowDraft?
    
    private var sharedViewModel: SwapSharedViewModel?
    private var noAccountViewModel: NoAccountViewModel?
    private var selectedAccount: Account?
    private var selectedAssetIn: AssetItem?
    private var selectedAssetOut: AssetItem?
    private var availableProviders: [SwapProviderV2] = []
    
    private lazy var swapAssetFlowCoordinator = SwapAssetFlowCoordinator(
        draft: SwapAssetFlowDraft(),
        dataStore: SwapDataLocalStore(),
        configuration: configuration,
        presentingScreen: self
    )
    private var confirmSwapDataController: ConfirmSwapDataController?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        swapAssetFlowCoordinator.onProvidersListLoaded = { [weak self] providers in
            guard let self else { return }
            availableProviders = providers.results
        }
        
        swapAssetFlowCoordinator.getProvidersList()
        configureView()
    }
    
    @objc private func appDidBecomeActive() {
        if launchDraft != nil { configureView() }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func customizeTabBarAppearence() {
        tabBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarHidden = false
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let sharedViewModel else { return }
        
        guard sharedViewModel.selectedNetwork == api?.network else {
            swapAssetFlowCoordinator.onProvidersListLoaded = { [weak self] providers in
                guard let self else { return }
                availableProviders = providers.results
            }
            swapAssetFlowCoordinator.getProvidersList()
            configureView()
            return
        }
        
        guard launchDraft == nil else {
            configureView()
            return
        }
        
        guard !sharedViewModel.payingText.isEmptyOrBlank else {
            resetAmounts()
            return
        }
        
        let value = Double(sharedViewModel.payingText.normalizedNumericString()) ?? 0
        if PeraUserDefaults.shouldUseLocalCurrencyInSwap ?? false {
            sharedViewModel.payingText = sharedViewModel.fiatFormat(with: value)
        } else {
            sharedViewModel.payingText = String(value)
        }
        
        sharedViewModel.updatePayingText(sharedViewModel.payingText) {  [weak self] doubleValue in
            guard let self else { return }
            handleSwapViewCallbacks(with: .getQuote(for: doubleValue))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - View Setup
    
    private func configureView() {
        sharedViewModel = nil
        
        if !resolveInitialState() {
            loadNoAccountView()
            loadSwapTopPairs()
            return
        }
        
        loadSwapView()
        loadSwapHistory()
        loadSwapTopPairs()
        
        swapAssetFlowCoordinator.showSwapIntroductionIfNeeded()
    }
    
    private func loadSwapView() {
        let swapHostingController = UIHostingController(
            rootView: createSwapView()
        )
        
        if let existingController = children.first(where: { $0 is UIHostingController<SwapView> }) {
            existingController.willMove(toParent: nil)
            existingController.view.removeFromSuperview()
            existingController.removeFromParent()
        }
        
        addChild(swapHostingController)
        swapHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(swapHostingController.view)
        swapHostingController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        swapHostingController.didMove(toParent: self)
    }
    
    private func loadNoAccountView() {
        let viewModel = noAccountViewModel ?? {
            let vm = NoAccountViewModel()
            self.noAccountViewModel = vm
            return vm
        }()
        var rootView = NoAccountSwapView(viewModel: viewModel)
        
        rootView.onAction = { [weak self] action in
            guard let self else { return }
            switch action {
            case .info:
                open(AlgorandWeb.tinymanSwap.link)
            case .createAccount:
                AppDelegate.shared?.launchOnboarding()
            }
        }
        let noAccountSwapHostingController = UIHostingController(rootView: rootView)
        addChild(noAccountSwapHostingController)
        noAccountSwapHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noAccountSwapHostingController.view)
        noAccountSwapHostingController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        noAccountSwapHostingController.didMove(toParent: self)
    }
    
    private func createSwapView() -> SwapView {
        guard let selectedAccount else {
            fatalError("No account selected")
        }
        
        let assetIn = resolveAssetIn(for: selectedAccount)
        let assetOut = resolveAssetOut(for: selectedAccount)
        
        self.selectedAssetIn = assetIn
        self.selectedAssetOut = assetOut
        
        let viewModel = sharedViewModel ?? {
            let vm = SwapSharedViewModel(
                selectedAccount: selectedAccount,
                selectedAssetIn: assetIn,
                selectedAssetOut: assetOut,
                selectedNetwork: api?.network ?? .mainnet,
                currency: sharedDataController.currency,
                sharedDataController: sharedDataController
            )
            self.sharedViewModel = vm
            return vm
        }()
        
        update(viewModel, with: selectedAccount, assetIn: assetIn, assetOut: assetOut)
        viewModel.availableProviders = availableProviders
        
        var rootView = SwapView(viewModel: viewModel)
        
        rootView.onAction = { [weak self] action in
            guard let self else { return }
            handleSwapViewCallbacks(with: action)
        }
        
        return rootView
    }
    
    private func loadSwapHistory() {
        guard let selectedAccount else { return }
        
        swapAssetFlowCoordinator.onHistoryListLoaded = { [weak self] result, error in
            guard let self else { return }
            if let error {
                bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: error.prettyDescription)
                sharedViewModel?.swapHistoryList = nil
                return
            }
            sharedViewModel?.swapHistoryList = result?.results ?? []
        }
        swapAssetFlowCoordinator.swapHistoryList(with: selectedAccount.address, statuses: [SwapStatus.completed.rawValue, SwapStatus.inProgress.rawValue].joined(separator: ","))
    }
    
    private func loadSwapTopPairs() {
        swapAssetFlowCoordinator.onTopPairsListLoaded = { [weak self] result, error in
            guard let self else { return }
            if let error {
                bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: error.prettyDescription)
                sharedViewModel?.swapTopPairsList = []
                noAccountViewModel?.swapTopPairsList = []
                return
            }
            sharedViewModel?.swapTopPairsList = result?.results ?? []
            noAccountViewModel?.swapTopPairsList = result?.results ?? []
        }
        
        swapAssetFlowCoordinator.swapTopPairsList()
    }
    
    // MARK: - Actions
    
    private func confirmSwap() {
        guard let viewModel = sharedViewModel else { return }
        
        let swapController = makeSwapController(with: viewModel)
        
        swapController.eventHandler = {
            [weak self] event in
            guard let self else { return }
            handleSwapControllerCallbacks(with: event, from: swapController)
        }
        let dataController = ConfirmSwapAPIDataController(
            swapController: swapController,
            api: configuration.api!,
            featureFlagService: configuration.featureFlagService
        )
        self.confirmSwapDataController = dataController
        
        confirmSwapDataController?.eventHandler = { [weak self] event in
            guard let self else { return }
            handleConfirmSwapControllerCallbacks(with: event, from: swapController)
        }
        confirmSwapDataController?.confirmSwap()
    }
    
    // MARK: - Helpers
    
    private func resetAmounts() {
        if PeraUserDefaults.shouldUseLocalCurrencyInSwap ?? false {
            sharedViewModel?.payingText = sharedViewModel?.fiatFormat(with: 0.0) ?? SwapSharedViewModel.defaultAmountValue
            sharedViewModel?.payingTextInSecondaryCurrency = SwapSharedViewModel.defaultAmountValue
            sharedViewModel?.receivingText = sharedViewModel?.fiatFormat(with: 0.0) ?? SwapSharedViewModel.defaultAmountValue
            sharedViewModel?.receivingTextInSecondaryCurrency = SwapSharedViewModel.defaultAmountValue
        } else {
            sharedViewModel?.payingText = .empty
            sharedViewModel?.payingTextInSecondaryCurrency = sharedViewModel?.fiatFormat(with: 0.0) ?? SwapSharedViewModel.defaultAmountValue
            sharedViewModel?.receivingText = .empty
            sharedViewModel?.receivingTextInSecondaryCurrency = sharedViewModel?.fiatFormat(with: 0.0) ?? SwapSharedViewModel.defaultAmountValue
        }
       
        sharedViewModel?.isBalanceNotSufficient = false
        sharedViewModel?.swapConfirmationState = .idle
    }
    
    private func resolveDefaultAccount() -> Account? {
        let validAccounts = sharedDataController.accountCollection
            .filter { !$0.value.isWatchAccount && $0.value.canSignTransaction }
        
        if let lastAddressUsed = PeraUserDefaults.lastAddressUsedInSwapCompleted,
           let lastUsedAccount = validAccounts.first(where: { $0.value.address == lastAddressUsed })?
            .value {
            return lastUsedAccount
        }
        
        return validAccounts.min(by: { $0.value.preferredOrder < $1.value.preferredOrder })?.value
    }
    
    private func resolveInitialState() -> Bool {
        guard let account = launchDraft?.account ?? selectedAccount ?? resolveDefaultAccount() else { return false }
        selectedAccount = account
        defer { launchDraft = nil }
        
        guard let launchDraft else {
            selectedAssetIn = nil
            selectedAssetOut = nil
            return true
        }
        
        if let assetOut = launchDraft.assetOut {
            selectedAssetOut = assetItem(from: assetOut)
            selectedAssetIn = launchDraft.assetIn
                .map { assetItem(from: $0) }
                ?? assetItem(from: resolveAsset(with: launchDraft.assetInID, for: selectedAccount))
            return true
        }
        
        if let assetIn = launchDraft.assetIn {
            selectedAssetIn = assetItem(from: assetIn)
            if let assetOutID = launchDraft.assetOutID {
                selectedAssetOut = assetItem(from: resolveAsset(with: assetOutID, for: selectedAccount))
            } else {
                selectedAssetOut = assetItem(from: assetIn)
                selectedAssetIn = assetIn.isAlgo
                    ? resolveDefaultUSDCAsset(for: account)
                    : resolveDefaultAlgoAsset(for: account)
            }
            return true
        }
        
        if let assetOutId = launchDraft.assetOutID {
            if let assetOut = assetFromAssetDetailCollection(with: assetOutId) {
                guard launchDraft.assetInID > 0 else {
                    selectedAssetOut = assetItem(from: assetOut)
                    selectedAssetIn = assetOut.isAlgo
                    ? resolveDefaultUSDCAsset(for: account)
                    : resolveDefaultAlgoAsset(for: account)
                    return true
                }
                selectedAssetIn = assetItem(from: resolveAsset(with: launchDraft.assetInID, for: selectedAccount))
                selectedAssetOut = assetItem(from: assetOut)
            } else {
                swapAssetFlowCoordinator.onAssetLoaded = { [weak self] assetLoaded in
                    guard let self else { return }
                    guard let assetLoaded else {
                        bannerController?.presentErrorBanner(
                            title: String(localized: "title-error"),
                            message: String(localized: "asset-confirmation-not-fetched")
                        )
                        return
                    }
                    selectedAssetOut = assetItem(from: assetLoaded)
                    if launchDraft.assetInID == 0 {
                        selectedAssetIn = resolveDefaultAlgoAsset(for: account)
                    } else {
                        selectedAssetIn = assetItem(from: resolveAsset(with: launchDraft.assetInID, for: selectedAccount))
                    }
                    loadSwapView()
                }
                swapAssetFlowCoordinator.fetchAsset(with: assetOutId)
            }
            return true
        }
        
        selectedAssetIn = nil
        selectedAssetOut = nil
        return true
    }
    
    private func resolveAssetIn(for account: Account) -> AssetItem {
        guard let selectedAssetIn else {
            return resolveDefaultAlgoAsset(for: account)
        }
        return selectedAssetIn
    }
    
    private func resolveAssetOut(for account: Account) -> AssetItem {
        guard let selectedAssetOut else {
            return resolveDefaultUSDCAsset(for: account)
        }
        return selectedAssetOut
    }
    
    private func assetItem(from asset: Asset?) -> AssetItem? {
        guard let asset else { return nil }
        let assetItem = AssetItem(
            asset: asset,
            currency: sharedDataController.currency,
            currencyFormatter: .init(),
            isAmountHidden: false
        )
        return assetItem
    }
    
    private func resolveDefaultAlgoAsset(for account: Account?) -> AssetItem {
        guard
            let asset = account?[0],
            let assetItem = assetItem(from: asset)
        else {
            fatalError("No algo asset available for account")
        }
        return assetItem
    }
    
    private func resolveDefaultUSDCAsset(for account: Account?) -> AssetItem {
        let network = api?.network ?? .mainnet
        let usdcAssetID = ALGAsset.usdcAssetID(network)
        
        if
            let asset = resolveAsset(with: usdcAssetID, for: account),
            let assetItem = assetItem(from: asset)
        {
            return assetItem
        }
        
        guard
            let asset = assetFromAssetDetailCollection(with: usdcAssetID),
            let defaultAsset = assetItem(from: asset)
        else {
            return resolveDefaultAlgoAsset(for: account)
        }
        
        return defaultAsset
    }
    
    private func resolveAsset(with assetID: AssetID, for account: Account?) -> Asset? {
        if let asset = selectedAccount?.allAssets?.filter({ $0.id == assetID }).first {
            return asset
        }
        return assetFromAssetDetailCollection(with: assetID)
    }
    
    private func assetFromAssetDetailCollection(with assetId: AssetID) -> Asset? {
        guard
            !sharedDataController.assetDetailCollection.isEmpty,
            let assetDecorationElement = sharedDataController.assetDetailCollection.filter({ $0.id == assetId}).first
        else
        {
            return nil
        }
        return StandardAsset(decoration: assetDecorationElement)
    }
    
    private func resetViewAfterSwap() {
        /// force balance update if asset is algo
        let shouldForceUpdate = (selectedAssetIn?.asset.isAlgo == true) || (selectedAssetOut?.asset.isAlgo == true)
        
        if
            shouldForceUpdate,
            let address = selectedAccount?.address,
            let account = sharedDataController.accountCollection.first(where: { $0.value.address == address })?.value
        {
            selectedAccount = account

            if selectedAssetIn?.asset.isAlgo == true {
                selectedAssetIn = resolveDefaultAlgoAsset(for: account)
            }

            if selectedAssetOut?.asset.isAlgo == true {
                selectedAssetOut = resolveDefaultAlgoAsset(for: account)
            }
        }
        
        resetAmounts()
        loadSwapView()
        loadSwapHistory()
    }
    
    private func update(
        _ viewModel: SwapSharedViewModel,
        with account: Account,
        assetIn: AssetItem,
        assetOut: AssetItem
    ) {
        if account.address != viewModel.selectedAccount.address {
            viewModel.selectedAccount = account
        }
        viewModel.selectedAssetIn = assetIn
        viewModel.selectedAssetOut = assetOut
    }
    
    private func update(
        _ viewModel: SwapSharedViewModel?,
        with quoteList: [SwapQuote]?
    ) {
        guard let viewModel, let quoteList, let selectedAssetIn, let selectedAssetOut else { return }
        
        var orderedQuoteList: [SwapQuote] {
            let shouldFilterDeflex = configuration.featureFlagService.isEnabled(.ledgerDeflexFilterEnabled)
                && (selectedAccount?.authorization.isLedger ?? false)
            
            return quoteList
                .sorted { ($0.amountOutUSDValue ?? 0) > ($1.amountOutUSDValue ?? 0) }
                .filter { !shouldFilterDeflex || $0.provider?.rawValue != "deflex" }
        }
        
        let selectedQuote = orderedQuoteList.first
        
        let amountOut = selectedQuote?.amountOut ?? 0
        let decimalsOut = selectedQuote?.assetOut?.decimals ?? 0
        let valueOut = Decimal(amountOut) / pow(10, decimalsOut)
        
        let amountIn = selectedQuote?.amountIn ?? 0
        let decimalsIn = selectedQuote?.assetIn?.decimals ?? 0
        let valueIn = Decimal(amountIn) / pow(10, decimalsIn)
        
        
        if PeraUserDefaults.shouldUseLocalCurrencyInSwap ?? false {
            viewModel.receivingText = viewModel.fiatValueText(fromAsset: selectedAssetOut.asset, with: valueOut.doubleValue)
            viewModel.receivingTextInSecondaryCurrency = Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 6).string(for: valueOut) ?? .empty
            
            let amountIn = selectedQuote?.amountIn ?? 0
            let decimalsIn = selectedQuote?.assetIn?.decimals ?? 0
            let valueIn = Decimal(amountIn) / pow(10, decimalsIn)
            viewModel.payingTextInSecondaryCurrency = Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 6).string(for: valueIn.doubleValue) ?? .empty
        } else {
            viewModel.receivingText = Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 8).string(for: valueOut) ?? .empty
            viewModel.receivingTextInSecondaryCurrency = viewModel.fiatValueText(fromAsset: selectedAssetOut.asset, with: valueOut.doubleValue)
            viewModel.payingTextInSecondaryCurrency = viewModel.fiatValueText(fromAsset: selectedAssetIn.asset, with: valueIn.doubleValue)
        }
        
        viewModel.quoteList = orderedQuoteList
        viewModel.selectedQuote = selectedQuote
        viewModel.isLoadingReceiveAmount = false
    }
    
    private func makeSwapController(with viewModel: SwapSharedViewModel) -> ALGSwapController {
        let transactionSigner = SwapTransactionSigner(
            api: configuration.api!,
            analytics: analytics,
            hdWalletStorage: hdWalletStorage,
            sharedDataController: sharedDataController
        )
        let swapControllerDraft = ALGSwapControllerDraft(
            account: viewModel.selectedAccount,
            assetIn: viewModel.selectedAssetIn.asset,
            assetOut: viewModel.selectedAssetOut.asset
        )
        let swapController = ALGSwapController(
            draft: swapControllerDraft,
            api: configuration.api!,
            transactionSigner: transactionSigner
        )
        swapController.quote = viewModel.selectedQuote
        swapController.providersV2 = availableProviders
        swapController.slippage = viewModel.slippageSelected.map { Decimal(floatLiteral: $0.value) }
        
        return swapController
    }
    
    // MARK: - Callbacks
    
    private func handleSwapViewCallbacks(
        with action: SwapViewAction
    ) {
        switch action {
        case .showInfo:
            open(AlgorandWeb.tinymanSwap.link)
        case .selectAccount:
            swapAssetFlowCoordinator.onAccountSelected = { [weak self] account in
                guard let self else { return }
                resetAmounts()
                selectedAssetIn = nil
                selectedAssetOut = nil
                selectedAccount = account
                loadSwapView()
                loadSwapHistory()
            }
            swapAssetFlowCoordinator.openSelectAccount()
            analytics.track(.swapV2SelectAccountEvent(type: .selectAccount))
        case let .selectAssetIn(account):
            swapAssetFlowCoordinator.onAssetInSelected = { [weak self] assetIn in
                guard let self else { return }
                analytics.track(.swapV2SelectAssetEvent(type: .selectTopAsset, assetName: assetIn.naming.displayNames.primaryName))
                selectedAssetIn = assetItem(from: assetIn)
                if selectedAssetIn?.asset.id == selectedAssetOut?.asset.id {
                    if selectedAssetIn?.asset.isAlgo ?? false {
                        selectedAssetOut = resolveDefaultUSDCAsset(for: account)
                    } else if selectedAssetIn?.asset.isUSDC(for: api?.network ?? .mainnet) ?? false {
                        selectedAssetOut = resolveDefaultAlgoAsset(for: account)
                    }
                }
                loadSwapView()
                guard let payingText = sharedViewModel?.payingText else {
                    return
                }
                sharedViewModel?.updatePayingText(payingText) { [weak self] doubleValue in
                    guard let self else { return }
                    handleSwapViewCallbacks(with: .getQuote(for: doubleValue))
                }
            }
            swapAssetFlowCoordinator.openSelectAssetIn(account: account)
        case let .selectAssetOut(account):
            swapAssetFlowCoordinator.onAssetOutSelected = { [weak self] assetOut in
                guard let self else { return }
                analytics.track(.swapV2SelectAssetEvent(type: .selectBottomAsset, assetName: assetOut.naming.displayNames.primaryName))
                selectedAssetOut = assetItem(from: assetOut)
                loadSwapView()
                guard let payingText = sharedViewModel?.payingText else {
                    return
                }
                sharedViewModel?.updatePayingText(payingText) { [weak self] doubleValue in
                    guard let self else { return }
                    handleSwapViewCallbacks(with: .getQuote(for: doubleValue))
                }
            }
            swapAssetFlowCoordinator.openSelectAssetOut(account: account, assetIn: selectedAssetIn?.asset)
        case .onSwitchAssets:
            selectedAssetIn = sharedViewModel?.selectedAssetIn
            selectedAssetOut = sharedViewModel?.selectedAssetOut
        case let .getQuote(value):
            swapAssetFlowCoordinator.onQuoteLoaded = { [weak self] quoteList, error in
                guard let self else { return }
                if let error {
                    bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: error.prettyDescription)
                    sharedViewModel?.isLoadingReceiveAmount = false
                    return
                }
                
                update(sharedViewModel, with: quoteList)
                loadSwapView()
            }
            
            guard let selectedAccount, let assetIn = selectedAssetIn?.asset, let assetOut = selectedAssetOut?.asset else {
                bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: .empty)
                return
            }
            swapAssetFlowCoordinator.getQuote(account: selectedAccount, assetIn: assetIn, assetOut: assetOut, amount: value, slippage: sharedViewModel?.slippageSelected.map { Decimal(floatLiteral: $0.value) })
        case let .calculatePeraFee(amount, percentage):
            guard let assetIn = selectedAssetIn?.asset else { return }
            swapAssetFlowCoordinator.onFeeCalculated = { [weak self] response, error in
                guard let self else { return }
                if let error {
                    bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: error.prettyDescription)
                    sharedViewModel?.isLoadingPayAmount = false
                    return
                }
                let swapAmount = calculateSwapAmount(for: assetIn, balance: Decimal(amount), peraSwapFee: response, percentage: Decimal(percentage))
                
                if PeraUserDefaults.shouldUseLocalCurrencyInSwap ?? false {
                    sharedViewModel?.payingText = sharedViewModel?.fiatValueText(fromAlgo: swapAmount.doubleValue) ?? .empty
                    sharedViewModel?.payingTextInSecondaryCurrency = Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 8).string(for: swapAmount) ?? .empty
                } else {
                    sharedViewModel?.payingText = Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 8).string(for: swapAmount) ?? .empty
                    sharedViewModel?.payingTextInSecondaryCurrency = sharedViewModel?.fiatValueText(fromAlgo: swapAmount.doubleValue) ?? .empty
                }
                
                guard swapAmount.doubleValue > 0 else {
                    sharedViewModel?.isLoadingPayAmount = false
                    sharedViewModel?.isLoadingReceiveAmount = false
                    sharedViewModel?.isBalanceNotSufficient = true
                    return
                }
                
                sharedViewModel?.isLoadingPayAmount = false
                sharedViewModel?.isLoadingReceiveAmount = true
                handleSwapViewCallbacks(with: .getQuote(for: swapAmount.doubleValue))
            }
            
            swapAssetFlowCoordinator.calculateFee(assetIn: assetIn, amount: amount)
        case let .selectSwap(swapAssetIn, swapAssetOut):
            if let assetIn = asset(from: swapAssetIn) {
                selectedAssetIn = assetItem(from: assetIn)
            }
            if let assetOut = asset(from: swapAssetOut) {
                selectedAssetOut = assetItem(from: assetOut)
            }
            let payingText = sharedViewModel?.payingText ?? .empty
            resetAmounts()
            sharedViewModel?.payingText = payingText
            sharedViewModel?.updatePayingText(payingText) { [weak self] doubleValue in
                guard let self else { return }
                handleSwapViewCallbacks(with: .getQuote(for: doubleValue))
            }
            loadSwapView()
        case let .openExplorer(transactionGroupId, pairing):
            guard let formattedGroupID = transactionGroupId.addingPercentEncoding(withAllowedCharacters: .alphanumerics),
                  let url = AlgorandWeb.PeraExplorer.group(
                    isMainnet: api?.network == .mainnet,
                    param: formattedGroupID
                  ).link else {
                return
            }
            analytics.track(.swapV2HistoryEvent(type: .selectHistoryInSeeAll, swapPairing: pairing))
            guard let presentedViewController else {
                openInBrowser(url)
                return
            }
            open(url, from: presentedViewController)
        case .confirmSwap:
            analytics.track(.swapV2ConfirmEvent(type: .confirmSlide))
            confirmSwap()
        case let .showSwapConfirmationBanner(successMessage, errorMessage):
            guard let successMessage else {
                bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: errorMessage ?? .empty)
                sharedViewModel?.swapConfirmationState = .idle
                return
            }
            bannerController?.presentSuccessBanner(title: successMessage)
            resetViewAfterSwap()

        case let .trackAnalytics(event):
            switch event {
            case .swapHistorySeeAll:
                analytics.track(.swapV2HistoryEvent(type: .historySeeAll, swapPairing: nil))
            case .swapHistorySelect(pairing: let pairing):
                analytics.track(.swapV2HistoryEvent(type: .selectHistory, swapPairing: pairing))
            case .swapTopPairSelect(pairing: let pairing):
                analytics.track(.swapV2TopPairEvent(type: .selectTopPair, swapPairing: pairing))
            case .swapSelectProvider:
                analytics.track(.swapV2ProviderEvent(type: .selectProviderOpen, routerName: nil))
            case .swapSelectProviderClose:
                analytics.track(.swapV2ProviderEvent(type: .selectProviderClose, routerName: nil))
            case .swapSelectProviderApply:
                analytics.track(.swapV2ProviderEvent(type: .selectProviderApply, routerName: nil))
            case .swapSelectProviderRouter(name: let name):
                analytics.track(.swapV2ProviderEvent(type: .selectProviderRouter, routerName: name))
            case .swapSettingsClose:
                analytics.track(.swapV2SettingsEvent(type: .settingsClose, value: nil))
            case .swapSettingsApply:
                analytics.track(.swapV2SettingsEvent(type: .settingsApply, value: nil))
            case .swapSettingsPercentage(value: let value):
                analytics.track(.swapV2SettingsEvent(type: .settingsPercentageSelected, value: value))
            case .swapSettingsSlippage(value: let value):
                analytics.track(.swapV2SettingsEvent(type: .settingsSlippageSelected, value: value))
            case .swapSettingsLocalCurrency(on: let isOn):
                if isOn {
                    analytics.track(.swapV2SettingsEvent(type: .settingsLocalCurrencyOn, value: nil))
                } else {
                    analytics.track(.swapV2SettingsEvent(type: .settingsLocalCurrencyOff, value: nil))
                }
            case .swapConfirmTapped:
                analytics.track(.swapV2ConfirmEvent(type: .confirmSwap))
            }
        }
    }
    
    private func calculateSwapAmount(for asset: Asset, balance: Decimal, peraSwapFee: PeraSwapV2Fee?, percentage: Decimal) -> Decimal {
        guard let peraSwapFee else { return 0 }
        
        let peraFee = peraSwapFee.fee?.assetAmount(fromFraction: asset.decimals) ?? 0
        let minBalance = asset.isAlgo ? selectedAccount?.calculateMinBalance().assetAmount(fromFraction: asset.decimals) ?? 0 : 0
        var paddingFee: Decimal {
            guard asset.isAlgo else {
                return 0
            }
            if let feePadding = configuration.featureFlagService.double(for: .swapFeePadding) {
                return Decimal(feePadding)
            } else {
                return SwapQuote.feePadding.assetAmount(fromFraction: asset.decimals)
            }
        }
        let desired = balance * percentage
        let maxTradable = max(balance - peraFee - minBalance - paddingFee, 0)
        return min(desired, maxTradable)
    }
    
    private func asset(from swapAsset: SwapAsset) -> Asset? {
        guard let selectedAccount else { return nil }
        
        if let asset = selectedAccount[swapAsset.assetID] {
            return asset
        }
        
        if let asset = selectedAccount.allAssets?.filter({ $0.id == swapAsset.assetID }).first {
            return asset
        }
        
        if
            !sharedDataController.assetDetailCollection.isEmpty,
            let assetDecorationElement = sharedDataController.assetDetailCollection.filter({ $0.id == swapAsset.assetID}).first
        {
            return StandardAsset(decoration: assetDecorationElement)
        }
        
        return StandardAsset(swapAsset: swapAsset)
    }
    
    private func handleSwapControllerCallbacks(
        with event: SwapControllerEvent,
        from swapController: SwapController
    ) {
        switch event {
        case .didSignTransaction:
            guard let selectedAccount else { return }
            swapAssetFlowCoordinator.swapAssetDidSignTransaction(account: selectedAccount, swapController: swapController)
        case let .didLedgerRequestUserApproval(ledger, transactionGroups):
            swapAssetFlowCoordinator.swapAssetDidLedgerRequestUserApproval(ledger: ledger, transactionGroups: transactionGroups, swapController: swapController)
        case .didSignAllTransactions, .didFinishTiming, .didLedgerResetOnSuccess, .didLedgerRejectSigning:
            break
        case .didCompleteSwap:
            if let quote = swapController.quote {
                self.analytics.track(
                    .swapCompleted(
                        quote: quote,
                        parsedTransactions: swapController.parsedTransactions,
                        currency: self.sharedDataController.currency
                    )
                )
            }
            PeraUserDefaults.lastAddressUsedInSwapCompleted = selectedAccount?.address
            swapAssetFlowCoordinator.updateSwapStatus(swapController: swapController, status: .inProgress)
            sharedViewModel?.swapConfirmationState = .success
        case .didFailTransaction(let txnID):
            guard let quote = swapController.quote else { return }
            swapAssetFlowCoordinator.logFailedSwap(
                quote: quote,
                txnID: txnID,
                swapController: swapController,
                failureReason: .blockchainError
            )
            swapController.clearTransactions()
            sharedViewModel?.swapConfirmationState = .error(nil)
        case .didFailNetwork(let error):
            guard let quote = swapController.quote else { return }
            swapAssetFlowCoordinator.logFailedSwap(
                quote: quote,
                error: error,
                swapController: swapController,
                failureReason: .blockchainError
            )
            swapController.clearTransactions()
            sharedViewModel?.swapConfirmationState = .error(error)
        case .didCancelTransaction, .didLedgerReset:
            swapAssetFlowCoordinator.updateSwapStatus(swapController: swapController, status: .failed, failureReason: .userCancelled)
            swapController.clearTransactions()
            sharedViewModel?.swapConfirmationState = .idle
        case .didFailSigning(let error):
            swapAssetFlowCoordinator.updateSwapStatus(swapController: swapController, status: .failed, failureReason: .other)
            sharedViewModel?.swapConfirmationState = .error(error)
        }
    }
    
    private func handleConfirmSwapControllerCallbacks(
        with event: ConfirmSwapDataControllerEvent,
        from swapController: SwapController
    ) {
        switch event {
        case .willUpdateSlippage, .didUpdateSlippage, .willPrepareTransactions: break
        case .didFailToPrepareTransactions(let error), .didFailToUpdateSlippage(let error):
            bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: error.prettyDescription)
            sharedViewModel?.swapConfirmationState = .idle
        case .didPrepareTransactions(let swapTransactionPreparation):
            swapController.uploadSwapInfo(swapId: swapTransactionPreparation.swapId, swapVersion: swapTransactionPreparation.swapVersion)
            let transactionGroups = swapTransactionPreparation.transactionGroups
            if swapController.account.requiresLedgerConnection() {
                swapAssetFlowCoordinator.openSignWithLedgerConfirmation(
                    swapController: swapController,
                    transactionGroups: transactionGroups
                )
                return
            }
            
            
            swapController.signTransactions(transactionGroups)
        }
    }
}
