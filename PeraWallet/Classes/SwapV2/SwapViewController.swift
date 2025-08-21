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
    
    private lazy var transitionToHighPriceImpactWarning = BottomSheetTransition(presentingViewController: self)
    
    // MARK: - Initialisers
    
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
        
        if
            let launchDraft,
            let account = launchDraft.account
        {
            self.selectedAccount = account
            self.selectedAssetIn = assetItem(from: launchDraft.assetIn)
            self.selectedAssetOut = launchDraft.assetIn?.isAlgo ?? false ? nil : assetItem(from: account[0])!
            self.sharedViewModel = nil
            loadSwapView()
            self.launchDraft = nil
        } else {
            let defaultAccount = sharedDataController.accountCollection.map { $0.value }.filter { !$0.isWatchAccount }.first
            guard let defaultAccount else { return }
            
            self.selectedAccount = defaultAccount
            self.selectedAssetIn = nil
            self.selectedAssetOut = nil
            self.sharedViewModel = nil
            loadSwapView()
        }
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

    private func createSwapView() -> SwapView {
        guard let selectedAccount else {
            fatalError()
        }
        
        var assetIn: AssetItem {
            guard let selectedAssetIn else {
                return assetItem(from: selectedAccount[0])!
            }
            return selectedAssetIn
        }
        self.selectedAssetIn = assetIn
        
        var assetOut: AssetItem {
            guard let selectedAssetOut else {
                return usdcDefaultAsset()
            }
            return selectedAssetOut
        }
        self.selectedAssetOut = assetOut
        
        var rootView: SwapView
        
        if let sharedViewModel {
            if
                let account = self.selectedAccount,
                account.address != sharedViewModel.selectedAccount.address
            {
                sharedViewModel.selectedAccount = account
            }
            
            if
                let assetIn = self.selectedAssetIn,
                assetIn.asset.id != sharedViewModel.selectedAssetIn.asset.id
            {
                sharedViewModel.selectedAssetIn = assetIn
            }
               
            if
                let assetOut = self.selectedAssetOut,
                assetOut.asset.id != sharedViewModel.selectedAssetOut.asset.id
            {
                sharedViewModel.selectedAssetOut = assetOut
            }
            sharedViewModel.availableProviders = availableProviders
            
            rootView = SwapView(viewModel: sharedViewModel)
        } else {
            let viewModel = SwapSharedViewModel(
                selectedAccount: selectedAccount,
                selectedAssetIn: assetIn,
                selectedAssetOut: assetOut
            )
            viewModel.availableProviders = availableProviders
            self.sharedViewModel = viewModel
            
            rootView = SwapView(viewModel: viewModel)
        }
        
        rootView.onTap = { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .showInfo:
                open(AlgorandWeb.tinymanSwap.link)
            case .selectAccount:
                swapAssetFlowCoordinator.onAccountSelected = { [weak self] selectedAccount in
                    guard let self = self else { return }
                    self.selectedAccount = selectedAccount
                    loadSwapView()
                }
                swapAssetFlowCoordinator.openSelectAccount()
            case .selectAssetIn(for: let account):
                swapAssetFlowCoordinator.onAssetInSelected = { [weak self] selectedAssetIn in
                    guard let self = self else { return }
                    self.selectedAssetIn = assetItem(from: selectedAssetIn)
                    loadSwapView()
                }
                swapAssetFlowCoordinator.openSelectAssetIn(account: account)
            case .selectAssetOut(for: let account):
                swapAssetFlowCoordinator.onAssetOutSelected = { [weak self] selectedAssetOut in
                    guard let self = self else { return }
                    self.selectedAssetOut = assetItem(from: selectedAssetOut)
                    loadSwapView()
                }
                swapAssetFlowCoordinator.openSelectAssetOut(account: account)
            case .getQuote(for: let value):
                swapAssetFlowCoordinator.onQuoteLoaded = { [weak self] quoteList, error in
                    guard let self = self else { return }
                    if let error {
                        // TODO: show error alert
                        print(error)
                        return
                    }
                    let orderedQuoteList = quoteList?.sorted { $0.amountOutUSDValue ?? 0 > $1.amountOutUSDValue ?? 0}
                    sharedViewModel?.receivingText = Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 8).string(for: orderedQuoteList?.first?.amountOutUSDValue)
                    sharedViewModel?.quoteList = orderedQuoteList
                    sharedViewModel?.selectedQuote = orderedQuoteList?.first
                    sharedViewModel?.isLoadingQuote = false
                    loadSwapView()
                }
                guard let assetIn = selectedAssetIn?.asset, let assetOut = selectedAssetOut?.asset else {
                    // TODO: show error alert
                    return
                }
                swapAssetFlowCoordinator.getQuote(account: selectedAccount, assetIn: assetIn, assetOut: assetOut, amount: value)
            case .confirmSwap:
//                if let priceImpact = sharedViewModel?.quote?.priceImpact,
//                   priceImpact > PriceImpactLimit.tenPercent && priceImpact <= PriceImpactLimit.fifteenPercent {
//                    presentWarningForHighPriceImpact()
//                    return
//                }
                confirmSwap()
            }
        }
        
        return rootView
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
    
    private func usdcDefaultAsset() -> AssetItem {
        guard
            let network = api?.network,
            !sharedDataController.assetDetailCollection.isEmpty,
            let assetDecorationElement = sharedDataController.assetDetailCollection.filter({ $0.id == ALGAsset.usdcAssetID(network)}).first,
            let asset = assetItem(from: StandardAsset(decoration: assetDecorationElement))
        else {
            return assetItem(from: selectedAccount?[0])!
        }
        
        return asset
    }
    
    private func confirmSwap() {
        print("---Confirm swap")
        
        guard let viewModel = sharedViewModel else { return }
        
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
        
        swapController.eventHandler = {
            [weak self, weak swapController] event in
            guard let self = self,
                  let swapController = swapController,
                  let selectedAccount
            else {
                return
            }

            switch event {
            case .didSignTransaction:
//                if selectedAccount.requiresLedgerConnection(),
//                   let signWithLedgerProcessScreen = self.signWithLedgerProcessScreen {
//                    signWithLedgerProcessScreen.increaseProgress()
//
//                    if signWithLedgerProcessScreen.isProgressFinished {
//                        self.stopLoading()
//
//                        self.visibleScreen.dismissScreen {
//                            [weak self] in
//                            guard let self = self else { return }
//
//                            self.openSwapLoading(swapController)
//                        }
//                    }
//                }
                break
            case .didSignAllTransactions:
                if selectedAccount.requiresLedgerConnection() {
                    return
                }

//                self.stopLoading()
//                self.openSwapLoading(swapController)
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

//                self.openSwapSuccess(swapController)
            case .didFailTransaction(let txnID):
                guard let quote = swapController.quote else { return }

//                if !(self.visibleScreen is LoadingScreen) {
//                    return
//                }

                swapController.clearTransactions()
//                self.stopLoading()

//                logFailedSwap(
//                    quote: quote,
//                    txnID: txnID
//                )

//                let viewModel = SwapUnexpectedErrorViewModel(quote)
//                self.openError(
//                    swapController,
//                    viewModel: viewModel
//                ) {
//                    [weak self] in
//                    guard let self = self else { return }
//                    
//                    let screen = self.goBackToScreen(SwapAssetScreen.self)
//                    screen?.getSwapQuoteForCurrentInput()
//                }
            case .didFailNetwork(let error):
                guard let quote = swapController.quote else { return }

//                if !(self.visibleScreen is LoadingScreen) {
//                    return
//                }

                swapController.clearTransactions()
//                self.stopLoading()
//
//                logFailedSwap(
//                    quote: quote,
//                    error: error
//                )

//                let viewModel = SwapAPIErrorViewModel(
//                    quote: quote,
//                    error: error
//                )
//                self.openError(
//                    swapController,
//                    viewModel: viewModel
//                ) {
//                    [weak self] in
//                    guard let self = self else { return }
//
//                    let screen = self.goBackToScreen(SwapAssetScreen.self)
//                    screen?.getSwapQuoteForCurrentInput()
//                }
            case .didCancelTransaction:
                swapController.clearTransactions()
//                self.stopLoading()
            case .didFailSigning(let error):
                switch error {
                case .api(let apiError):
//                    self.displaySigningError(apiError)
                    break
                case .ledger(let ledgerError):
//                    self.displayLedgerError(
//                        swapController: swapController,
//                        ledgerError: ledgerError
//                    )
                    break
                }
            case .didLedgerRequestUserApproval(let ledger, let transactionGroups):
//                self.ledgerConnectionScreen?.dismiss(animated: true) {
//                    self.ledgerConnectionScreen = nil
//
//                    self.openSignWithLedgerProcess(
//                        swapController: swapController,
//                        ledger: ledger,
//                        transactionGroups: transactionGroups
//                    )
//                }
                break
            case .didFinishTiming:
                break
            case .didLedgerReset:
                swapController.clearTransactions()
//                self.stopLoading()

//                if self.visibleScreen is LedgerConnectionScreen {
//                    self.ledgerConnectionScreen?.dismissScreen()
//                    self.ledgerConnectionScreen = nil
//                    return
//                }
//
//                if self.visibleScreen is SignWithLedgerProcessScreen {
//                    self.signWithLedgerProcessScreen?.dismissScreen()
//                    self.signWithLedgerProcessScreen = nil
//                }
            case .didLedgerResetOnSuccess:
                break
            case .didLedgerRejectSigning:
                break
            }
        }
        
        let dataController = ConfirmSwapAPIDataController(
            swapController: swapController,
            api: configuration.api!
        )
        self.confirmSwapDataController = dataController
        
        confirmSwapDataController?.eventHandler = { [weak self] event in
            guard let self else { return }
            switch event {
            case .willUpdateSlippage:
                // TODO: start loading
                break
            case .didUpdateSlippage(_):
                break
            case .didFailToUpdateSlippage(_):
                break
            case .willPrepareTransactions:
                // TODO: start loading
                break
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
                break
            case .didFailToPrepareTransactions(_):
                break
            }
        }
        confirmSwapDataController?.confirmSwap()
    }
}
