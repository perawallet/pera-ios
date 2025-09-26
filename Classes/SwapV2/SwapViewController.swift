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

final class SwapViewController: BaseViewController {
    
    // MARK: - Properties
    
    var launchDraft: SwapAssetFlowDraft?
    
    private var sharedViewModel: SwapSharedViewModel?
    private var selectedAccount: Account?
    private var selectedAssetIn: AssetItem?
    private var selectedAssetOut: AssetItem?
    
    private lazy var swapAssetFlowCoordinator = SwapAssetFlowCoordinator(
        draft: SwapAssetFlowDraft(),
        dataStore: SwapDataLocalStore(),
        configuration: configuration,
        presentingScreen: self
    )
    private lazy var transitionToHighPriceImpactWarning = BottomSheetTransition(presentingViewController: self)
    
    // MARK: - Initialisers
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            self.selectedAssetOut = nil
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
        let defaultAsset = assetItem(from: selectedAccount[0])!
        
        var assetIn: AssetItem {
            guard let selectedAssetIn else {
                return defaultAsset
            }
            return selectedAssetIn
        }
        self.selectedAssetIn = assetIn
        
        var assetOut: AssetItem {
            guard let selectedAssetOut else {
                return defaultAsset
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
            
            rootView = SwapView(viewModel: sharedViewModel)
        } else {
            let viewModel = SwapSharedViewModel(
                selectedAccount: selectedAccount,
                selectedAssetIn: assetIn,
                selectedAssetOut: assetOut
            )
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
                
            case .switchAssets:
                let temp = selectedAssetIn
                selectedAssetIn = selectedAssetOut
                selectedAssetOut = temp
                loadSwapView()
            case .getQuote(for: let value):
                swapAssetFlowCoordinator.onQuoteLoaded = { [weak self] quote, error in
                    guard let self = self else { return }
                    if let error {
                        // TODO: show error alert
                        print(error)
                        return
                    }
                    sharedViewModel?.receivingText = Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 8).string(for: quote?.amountOutUSDValue)
                    sharedViewModel?.quote = quote
                    sharedViewModel?.isLoadingQuote = false
                    loadSwapView()
                }
                guard let assetIn = selectedAssetIn?.asset, let assetOut = selectedAssetOut?.asset else {
                    // TODO: show error alert
                    return
                }
                swapAssetFlowCoordinator.getQuote(account: selectedAccount, assetIn: assetIn, assetOut: assetOut, amount: value)
            case .confirmSwap:
                if let priceImpact = sharedViewModel?.quote?.priceImpact,
                   priceImpact > PriceImpactLimit.tenPercent && priceImpact <= PriceImpactLimit.fifteenPercent {
                    presentWarningForHighPriceImpact()
                    return
                }
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
        
        let confirmSwapDataController = ConfirmSwapAPIDataController(
            swapController: swapController,
            api: configuration.api!
        )
        
//        confirmSwapDataController.eventHandler = { [weak self] event in
//            guard let self else { return }
//            switch event {
//            case .willUpdateSlippage:
//                <#code#>
//            case .didUpdateSlippage(_):
//                <#code#>
//            case .didFailToUpdateSlippage(_):
//                <#code#>
//            case .willPrepareTransactions:
//                <#code#>
//            case .didPrepareTransactions(_):
//                <#code#>
//            case .didFailToPrepareTransactions(_):
//                <#code#>
//            }
//        }
        confirmSwapDataController.confirmSwap()
    }
}

extension SwapViewController {
    private func presentWarningForHighPriceImpact() {
        let title =
            String(localized: "swap-high-price-impact-warning-title")
                .bodyLargeMedium(alignment: .center)
        let body = makeHighPriceImpactWarningBody()

        let uiSheet = UISheet(
            image: "icon-info-red",
            title: title,
            body: body
        )

        uiSheet.bodyHyperlinkHandler = {
            [unowned self] in
            let visibleScreen = self.findVisibleScreen()
            visibleScreen.open(AlgorandWeb.tinymanSwapPriceImpact.link)
        }

        let confirmAction = makeHighPriceImpactWarningConfirmAction()
        uiSheet.addAction(confirmAction)

        let cancelAction = makeHighPriceImpactWarningCancelAction()
        uiSheet.addAction(cancelAction)

        transitionToHighPriceImpactWarning.perform(
            .sheetAction(
                sheet: uiSheet,
                theme: UISheetActionScreenImageTheme()
            ),
            by: .presentWithoutNavigationController
        )
    }

    private func makeHighPriceImpactWarningBody() -> UISheetBodyTextProvider {
        let body = String(localized: "swap-high-price-impact-warning-body")
        let bodyHighlightedText = String(localized: "swap-high-price-impact-warning-body-highlighted-text")

        var bodyHighlightedTextAttributes = Typography.bodyMediumAttributes(alignment: .center)
        bodyHighlightedTextAttributes.insert(.textColor(Colors.Helpers.positive.uiColor))

        let uiSheetBodyHighlightedText = UISheet.HighlightedText(
            text: bodyHighlightedText,
            attributes: bodyHighlightedTextAttributes
        )
        let uiSheetBody = UISheetBodyTextProvider(
            text: body.bodyRegular(alignment: .center),
            highlightedText: uiSheetBodyHighlightedText
        )

        return uiSheetBody
    }

    private func makeHighPriceImpactWarningConfirmAction() -> UISheetAction {
        return UISheetAction(
            title: String(localized: "swap-confirm-title"),
            style: .default
        ) { [weak self] in
            guard let self else { return }
            dismiss(animated: true) {  [weak self] in
                guard let self else { return }
                confirmSwap()
            }
        }
    }

    private func makeHighPriceImpactWarningCancelAction() -> UISheetAction {
        return UISheetAction(
            title: String(localized: "title-cancel"),
            style: .cancel
        ) { [weak self] in
            guard let self else { return }
            dismiss(animated: true)
        }
    }
}
