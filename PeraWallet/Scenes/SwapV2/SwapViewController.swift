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
        
        swapAssetFlowCoordinator.onProvidersListLoaded = { [weak self] providers in
            guard let self else { return }
            availableProviders = providers.results
        }
        
        swapAssetFlowCoordinator.getProvidersList()
    }
    
    override func customizeTabBarAppearence() {
        tabBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarHidden = false
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureView()
    }
    
    // MARK: - View Setup
    
    private func configureView() {
        sharedViewModel = nil
        
        if !resolveInitialState() {
            loadNoAccountView()
            return
        }
        
        loadSwapView()
        loadSwapTopPairs()
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
        var rootView = NoAccountSwapView()
        
        rootView.onAction = { [weak self] action in
            guard let self else { return }
            switch action {
            case .info:
                open(AlgorandWeb.tinymanSwap.link)
            case .createAccount:
                open(
                    .addAccount(flow: .addNewAccount(mode: .none)),
                    by: .customPresent(
                        presentationStyle: .fullScreen,
                        transitionStyle: nil,
                        transitioningDelegate: nil
                    )
                )
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
                currency: sharedDataController.currency
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
    
    private func loadSwapTopPairs() {
        swapAssetFlowCoordinator.onTopPairsListLoaded = { [weak self] result, error in
            guard let self else { return }
            if let error {
                bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: error.prettyDescription)
                return
            }
            sharedViewModel?.swapTopPairsList = result?.results ?? []
        }
        
        swapAssetFlowCoordinator.getSwapTopPairsList()
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
    
    private func resolveDefaultAccount() -> Account? {
        sharedDataController.accountCollection
            .filter { !$0.value.isWatchAccount }
            .min(by: { $0.value.preferredOrder < $1.value.preferredOrder })?
            .value
    }
    
    private func resolveInitialState() -> Bool {
        if let draft = launchDraft, let account = draft.account {
            selectedAccount = account
            selectedAssetIn = assetItem(from: draft.assetIn)
            selectedAssetOut = draft.assetIn?.isAlgo == true ? nil : resolveDefaultAlgoAsset(for: account)
            launchDraft = nil
            return true
        }
        
        if let defaultAccount = resolveDefaultAccount() {
            selectedAccount = defaultAccount
            selectedAssetIn = nil
            selectedAssetOut = nil
            return true
        }
        return false
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
            let usdcAsset = selectedAccount?.allAssets?.filter({ $0.id == usdcAssetID }).first,
            let usdcAssetItem = assetItem(from: usdcAsset)
        {
            return usdcAssetItem
        }
        
        guard
            !sharedDataController.assetDetailCollection.isEmpty,
            let assetDecorationElement = sharedDataController.assetDetailCollection.filter({ $0.id == usdcAssetID}).first,
            let defaultAsset = assetItem(from: StandardAsset(decoration: assetDecorationElement))
        else {
            return resolveDefaultAlgoAsset(for: account)
        }
        
        return defaultAsset
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
        guard let viewModel, let quoteList, let selectedAssetOut else { return }
        
        let orderedQuoteList = quoteList.sorted { $0.amountOutUSDValue ?? 0 > $1.amountOutUSDValue ?? 0}
        let selectedQuote = orderedQuoteList.first
        
        let amountOut = selectedQuote?.amountOut ?? 0
        let decimalsOut = selectedQuote?.assetOut?.decimals ?? 0
        let valueOut = Decimal(amountOut) / pow(10, decimalsOut)
        
        if PeraUserDefaults.shouldUseLocalCurrencyInSwap ?? false {
            viewModel.receivingText = viewModel.fiatValueText(fromAsset: selectedAssetOut.asset, with: valueOut.doubleValue)
            viewModel.receivingTextInSecondaryCurrency = Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 2).string(for: valueOut) ?? SwapSharedViewModel.defaultAmountValue
        } else {
            viewModel.receivingText = Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 8).string(for: valueOut) ?? SwapSharedViewModel.defaultAmountValue
            viewModel.receivingTextInSecondaryCurrency = Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 2).string(for: valueOut) ?? SwapSharedViewModel.defaultAmountValue
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
                selectedAssetIn = nil
                selectedAssetOut = nil
                selectedAccount = account
                loadSwapView()
            }
            swapAssetFlowCoordinator.openSelectAccount()
        case let .selectAssetIn(account):
            swapAssetFlowCoordinator.onAssetInSelected = { [weak self] selectedAssetIn in
                guard let self else { return }
                self.selectedAssetIn = assetItem(from: selectedAssetIn)
                loadSwapView()
            }
            swapAssetFlowCoordinator.openSelectAssetIn(account: account)
        case let .selectAssetOut(account):
            swapAssetFlowCoordinator.onAssetOutSelected = { [weak self] selectedAssetOut in
                guard let self else { return }
                self.selectedAssetOut = assetItem(from: selectedAssetOut)
                loadSwapView()
            }
            swapAssetFlowCoordinator.openSelectAssetOut(account: account)
        case let .getQuote(value):
            swapAssetFlowCoordinator.onQuoteLoaded = { [weak self] quoteList, error in
                guard let self else { return }
                if let error {
                    bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: error.prettyDescription)
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
            swapAssetFlowCoordinator.onFeeCalculated = { [weak self] peraFee, error in
                guard let self else { return }
                if let error {
                    bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: error.prettyDescription)
                    return
                }
                
                let swapAmount = calculateSwapAmount(for: assetIn, balance: amount.decimal, peraSwapFee: peraFee, percentage: percentage.decimal)
                
                if PeraUserDefaults.shouldUseLocalCurrencyInSwap ?? false {
                    sharedViewModel?.payingText = sharedViewModel?.fiatValueText(fromAlgo: swapAmount.doubleValue) ?? SwapSharedViewModel.defaultAmountValue
                    sharedViewModel?.payingTextInSecondaryCurrency = sharedViewModel?.algoFormat(with: swapAmount.doubleValue)  ?? SwapSharedViewModel.defaultAmountValue
                } else {
                    sharedViewModel?.payingText = Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 8).string(for: swapAmount) ?? SwapSharedViewModel.defaultAmountValue
                    sharedViewModel?.payingTextInSecondaryCurrency = sharedViewModel?.fiatValueText(fromAlgo: swapAmount.doubleValue) ?? SwapSharedViewModel.defaultAmountValue
                }

                sharedViewModel?.isLoadingPayAmount = false
            }
           
            swapAssetFlowCoordinator.calculateFee(assetIn: assetIn, amount: amount)
        case .confirmSwap:
            confirmSwap()
        case let .showBanner(successMessage, errorMessage):
            guard let successMessage else {
                bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: errorMessage ?? .empty)
                return
            }
            bannerController?.presentSuccessBanner(title: successMessage)
            configureView()
        }
    }
    
    private func calculateSwapAmount(for asset: Asset, balance: Decimal, peraSwapFee: PeraSwapFee?, percentage: Decimal) -> Decimal {
        guard let peraSwapFee else { return 0 }
        
        let peraFee = peraSwapFee.fee?.assetAmount(fromFraction: asset.decimals) ?? 0
        let paddingFee = configuration.featureFlagService.double(for: .swapFeePadding)?.decimal ?? SwapQuote.feePadding.assetAmount(fromFraction: asset.decimals)
        let minBalance = selectedAccount?.calculateMinBalance().assetAmount(fromFraction: asset.decimals) ?? 0
        let desired = balance * percentage
        let maxTradable = max(balance - peraFee - minBalance - paddingFee, 0)
        return min(desired, maxTradable)
    }
    
    private func handleSwapControllerCallbacks(
        with event: SwapControllerEvent,
        from swapController: SwapController
    ) {
        switch event {
        case .didSignTransaction, .didSignAllTransactions, .didLedgerRequestUserApproval, .didFinishTiming, .didLedgerResetOnSuccess, .didLedgerRejectSigning:
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
            sharedViewModel?.swapConfirmationState = .success
        case .didFailTransaction, .didFailNetwork:
            swapController.clearTransactions()
            sharedViewModel?.swapConfirmationState = .error
        case .didCancelTransaction, .didLedgerReset:
            swapController.clearTransactions()
        case .didFailSigning(let error):
            switch error {
            case .api:
                sharedViewModel?.swapConfirmationState = .error
            case .ledger:
                sharedViewModel?.swapConfirmationState = .error
            }
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
        case .didPrepareTransactions(let swapTransactionPreparation):
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
