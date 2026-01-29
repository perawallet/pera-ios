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

//   SwapSharedViewModel.swift

import SwiftUI
import Combine
import pera_wallet_core

class SwapSharedViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var selectedAccount: Account
    @Published var selectedAssetIn: AssetItem
    @Published var selectedAssetOut: AssetItem
    @Published var selectedProvider: SelectedProvider
    @Published var isLoadingPayAmount: Bool = false
    @Published var isBalanceNotSufficient: Bool = false
    @Published var isLoadingReceiveAmount: Bool = false
    @Published var selectedQuote: SwapQuote?
    
    @Published var payingText: String = .empty
    @Published var payingTextInSecondaryCurrency: String = .empty
    @Published var receivingText: String = .empty
    @Published var receivingTextInSecondaryCurrency: String = .empty
    
    @Published var swapConfirmationState: ConfirmSlideButtonState = .idle {
        didSet {
            if swapConfirmationState == .success {
                shouldUpdateAccounts = true
            }
        }
    }
    
    @Published var selectedNetwork: ALGAPI.Network
    @Published var slippageSelected: SlippageValue? = nil
    @Published var swapTopPairsList: [SwapTopPair] = []
    @Published var swapHistoryList: [SwapHistory]? = []
    
    // MARK: - Internal State / Private Properties
    private var debounceTask: Task<Void, Never>?

    private var shouldUpdateAccounts = false
    
    static let defaultAmountValue = Formatter.decimalFormatter(minimumFractionDigits: 2, maximumFractionDigits: 2).string(for: Decimal(0))!

    // MARK: - Services
    let currency: CurrencyProvider
    let sharedDataController: SharedDataController
    private let amountFormatter = SwapAmountFormatter()
    private let pricingService = SwapPricingService()
    private let currencyService: SwapCurrencyService
    
    // MARK: - Computed Properties
    private var useLocalCurrency: Bool {
        PeraUserDefaults.shouldUseLocalCurrencyInSwap ?? false
    }
    
    var shouldShowSwapButton: Bool {
        if isBalanceNotSufficient || isLoadingPayAmount || isLoadingReceiveAmount { return false }
        let paying = useLocalCurrency ? amountFormatter.numericValue(from: payingTextInSecondaryCurrency) : amountFormatter.numericValue(from: payingText)
        let receiving = useLocalCurrency ? amountFormatter.numericValue(from: receivingTextInSecondaryCurrency) : amountFormatter.numericValue(from: receivingText)
        return paying > 0 && receiving > 0
    }
    
    var providerRate: String {
        pricingService.providerRate(for: selectedQuote)
    }

    var activeProvider: SwapProviderV2? {
        let providerId: String?
        switch selectedProvider {
        case .auto: providerId = quoteList?.first?.provider?.rawValue
        case .provider(let id): providerId = id
        }
        return availableProviders?.first(where: { $0.name == providerId })
    }
    
    // MARK: - Internal State
    var quoteList: [SwapQuote]?
    var availableProviders: [SwapProviderV2]?
    
    // MARK: - Init & Deinit
    init(
        selectedAccount: Account,
        selectedAssetIn: AssetItem,
        selectedAssetOut: AssetItem,
        selectedNetwork: ALGAPI.Network,
        currency: CurrencyProvider,
        sharedDataController: SharedDataController
    ) {
        self.selectedAccount = selectedAccount
        self.selectedAssetIn = selectedAssetIn
        self.selectedAssetOut = selectedAssetOut
        self.selectedProvider = .auto
        self.selectedNetwork = selectedNetwork
        self.currency = currency
        self.sharedDataController = sharedDataController
        self.currencyService = SwapCurrencyService(currency: currency, amountFormatter: amountFormatter)
        
        sharedDataController.add(self)
    }

    deinit {
        sharedDataController.remove(self)
    }
    
    // MARK: - Swap Actions
    func switchAssets(onAssetsSwitched: @escaping () -> Void) {
        (selectedAssetIn, selectedAssetOut) = (selectedAssetOut, selectedAssetIn)
        receivingText = .empty
        payingTextInSecondaryCurrency = .empty
        receivingTextInSecondaryCurrency = .empty
        onAssetsSwitched()
    }
    
    func confirmSwapModel() -> SwapConfirmViewModel? {
        guard let activeProvider else {
            return nil
        }
        
        return SwapConfirmViewModel(
            selectedAccount: selectedAccount,
            selectedAssetIn: selectedAssetIn,
            selectedAssetOut: selectedAssetOut,
            selectedAssetInAmount: useLocalCurrency ? payingTextInSecondaryCurrency : payingText,
            selectedAssetOutAmount: useLocalCurrency ? receivingTextInSecondaryCurrency : receivingText,
            selectedAssetInAmountInSecondaryCurrency: useLocalCurrency ? payingText : payingTextInSecondaryCurrency,
            selectedAssetOutAmountInSecondaryCurrency: useLocalCurrency ? receivingText : receivingTextInSecondaryCurrency,
            price: pricingService.price(for: selectedQuote),
            provider: activeProvider,
            slippageTolerance: pricingService.slippageTolerance(for: selectedQuote),
            priceImpact: pricingService.priceImpact(for: selectedQuote),
            minimumReceived: pricingService.minimumReceived(for: selectedQuote),
            exchangeFee: pricingService.exchangeFee(for: selectedQuote),
            peraFee: pricingService.peraFee(for: selectedQuote),
            confirmationState: swapConfirmationState,
            selectedNetwork: selectedNetwork
        )
    }
    
    func selectQuote(with provider: SelectedProvider) {
        guard let quoteList else { return }
        switch provider {
        case .auto:
            selectedQuote = quoteList.first
        case .provider(let provider):
            selectedQuote = quoteList.first { $0.provider?.rawValue == provider}
        }
        
        guard let selectedQuote else { return }
        
        let amountOut = selectedQuote.amountOut ?? 0
        let decimalsOut = selectedQuote.assetOut?.decimals ?? 0
        let valueOut = Decimal(amountOut) / pow(10, decimalsOut)
        
        let amountIn = selectedQuote.amountIn ?? 0
        let decimalsIn = selectedQuote.assetIn?.decimals ?? 0
        let valueIn = Decimal(amountIn) / pow(10, decimalsIn)
        
        receivingText = amountFormatter.string(from: valueOut) ?? .empty
        
        if useLocalCurrency {
            receivingTextInSecondaryCurrency = amountFormatter.string(from: Decimal(valueOut.doubleValue), maxFractionDigits: 6) ?? .empty
            payingTextInSecondaryCurrency = amountFormatter.string(from: Decimal(valueIn.doubleValue), maxFractionDigits: 6) ?? .empty
        } else {
            receivingTextInSecondaryCurrency = currencyService.fiatValueText(fromUSDC: valueOut.doubleValue)
            payingTextInSecondaryCurrency = currencyService.fiatFormat(with: selectedQuote.amountInUSDValue?.doubleValue ?? 0)
        }
    }
    
    func updatePayingText(_ newValue: String, onGetQuote: @escaping (Double) -> Void) {
        debounceTask?.cancel()
        debounceTask = nil
        
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second debounce
            guard let self else { return }
            
            let doubleValue = amountFormatter.numericValue(from: newValue)
            if doubleValue > 0 {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    isBalanceNotSufficient = doubleValue > NSDecimalNumber(decimal: selectedAssetIn.asset.decimalAmount).doubleValue
                    isLoadingReceiveAmount = true
                    
                    let valueToUse = useLocalCurrency ? currencyService.algoValue(fromFiat: doubleValue) : doubleValue
                    onGetQuote(valueToUse)
                }
            } else {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    resetTextFields()
                }
            }
        }
    }
    
    func resetTextFields() {
        receivingText = useLocalCurrency ? currencyService.fiatFormat(with: 0.0) : .empty
        receivingTextInSecondaryCurrency = useLocalCurrency ? Self.defaultAmountValue : currencyService.fiatFormat(with: 0.0)
        payingText = useLocalCurrency ? currencyService.fiatFormat(with: 0.0) : .empty
        payingTextInSecondaryCurrency = useLocalCurrency ? Self.defaultAmountValue : currencyService.fiatFormat(with: 0.0)
    }
    
    func filterPayingText(_ input: String) -> String {
        let decimalSeparator = Locale.current.decimalSeparator ?? "."
        var hasDecimal = false

        let filtered = input.filter { char in
            if char.isNumber { return true }
            if String(char) == decimalSeparator && !hasDecimal {
                hasDecimal = true
                return true
            }
            return false
        }

        let value = amountFormatter.numericValue(from: filtered)
        guard value > 0 else { return filtered }

        if useLocalCurrency {
            return currencyService.fiatFormat(with: value)
        } else {
            return amountFormatter.string(from: Decimal(value)) ?? filtered
        }
    }
    
    // MARK: - Formatting Helpers
    func fiatFormat(with amount: Double) -> String {
        currencyService.fiatFormat(with: amount)
    }
    
    func fiatValueText(fromAsset asset: Asset, with amount: Double) -> String {
        currencyService.fiatValueText(fromAsset: asset, with: amount)
    }
    
    func fiatValueText(fromAlgo amount: Double) -> String {
        currencyService.fiatValueText(fromAlgo: amount)
    }

}
// MARK: - SharedDataControllerObserver
extension SwapSharedViewModel: SharedDataControllerObserver {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event,
           shouldUpdateAccounts {
            updateAccountIfNeeded()
            shouldUpdateAccounts = false
        }
    }

    private func updateAccountIfNeeded() {
        let account = selectedAccount
        guard let updatedAccount = sharedDataController.accountCollection[account.address] else { return }

        if !updatedAccount.isAvailable { return }

        selectedAccount = updatedAccount.value
        updateAssetIfNeeded(for: updatedAccount.value, on: sharedDataController)
    }

    private func updateAssetIfNeeded(for selectedAccount: Account, on sharedDataController: SharedDataController) {
        guard let newAssetIn = selectedAccount[selectedAssetIn.asset.id],
              let newAssetOut = selectedAccount[selectedAssetOut.asset.id] else {
            return
        }

        if isAssetUpdated(oldAsset: selectedAssetIn.asset, newAsset: newAssetIn),
           let assetDetail = sharedDataController.assetDetailCollection[newAssetIn.id] {
            let algAsset = ALGAsset(asset: newAssetIn)
            self.selectedAssetIn.asset = StandardAsset(asset: algAsset, decoration: assetDetail)
        }
        
        if isAssetUpdated(oldAsset: selectedAssetOut.asset, newAsset: newAssetOut),
           let assetDetail = sharedDataController.assetDetailCollection[newAssetOut.id] {
            let algAsset = ALGAsset(asset: newAssetOut)
            self.selectedAssetOut.asset = StandardAsset(asset: algAsset, decoration: assetDetail)
        }
    }

    private func isAssetUpdated(oldAsset: Asset, newAsset: Asset) -> Bool {
        return oldAsset.decimalAmount != newAsset.decimalAmount ||
            oldAsset.usdValue != newAsset.usdValue
    }
}
