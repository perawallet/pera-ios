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

// FIXME: This class mixes ViewModel and Model logic.
// It should be refactored to follow a proper MVVM structure by
// moving business and formatting logic into dedicated services.
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
    
    private var debounceWorkItem: DispatchWorkItem?
    
    private var shouldUpdateAccounts = false
    
    static let defaultAmountValue = Formatter.decimalFormatter(minimumFractionDigits: 2, maximumFractionDigits: 2).string(for: Decimal(0))!
    
    let currency: CurrencyProvider
    let sharedDataController: SharedDataController
    
    // MARK: - Internal State
    var quoteList: [SwapQuote]?
    var availableProviders: [SwapProviderV2]?
    
    // MARK: - Init
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
        
        sharedDataController.add(self)
    }

    deinit {
        sharedDataController.remove(self)
    }
    
    // MARK: - Helpers
    
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
        
        let useLocalCurrency = PeraUserDefaults.shouldUseLocalCurrencyInSwap ?? false
        
        return SwapConfirmViewModel(
            selectedAccount: selectedAccount,
            selectedAssetIn: selectedAssetIn,
            selectedAssetOut: selectedAssetOut,
            selectedAssetInAmount: useLocalCurrency ? payingTextInSecondaryCurrency : payingText,
            selectedAssetOutAmount: useLocalCurrency ? receivingTextInSecondaryCurrency : receivingText,
            selectedAssetInAmountInSecondaryCurrency: useLocalCurrency ? payingText : payingTextInSecondaryCurrency,
            selectedAssetOutAmountInSecondaryCurrency: useLocalCurrency ? receivingText : receivingTextInSecondaryCurrency,
            price: price,
            provider: activeProvider,
            slippageTolerance: slippageTolerance,
            priceImpact: priceImpact,
            minimumReceived: minimumReceived,
            exchangeFee: exchangeFee,
            peraFee: peraFee,
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
        
        receivingText = Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 8).string(for: valueOut) ?? .empty
        
        if PeraUserDefaults.shouldUseLocalCurrencyInSwap ?? false {
            receivingTextInSecondaryCurrency = Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 6).string(for: valueOut.doubleValue) ?? .empty
            
            let amountIn = selectedQuote.amountIn ?? 0
            let decimalsIn = selectedQuote.assetIn?.decimals ?? 0
            let valueIn = Decimal(amountIn) / pow(10, decimalsIn)
            payingTextInSecondaryCurrency = Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 6).string(for: valueIn.doubleValue) ?? .empty
        } else {
            receivingTextInSecondaryCurrency = fiatValueText(fromUSDC: valueOut.doubleValue)
            payingTextInSecondaryCurrency = fiatFormat(with: selectedQuote.amountInUSDValue?.doubleValue ?? 0)
        }
    }
    
    func updatePayingText(_ newValue: String, onGetQuote: @escaping (Double) -> Void) {
        debounceWorkItem?.cancel()
        
        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            let doubleValue = newValue.numericValue()
            if doubleValue > 0 {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    isBalanceNotSufficient = doubleValue > NSDecimalNumber(decimal: selectedAssetIn.asset.decimalAmount).doubleValue
                    isLoadingReceiveAmount = true
                    
                    if PeraUserDefaults.shouldUseLocalCurrencyInSwap ?? false {
                        onGetQuote(algoValue(fromFiat: doubleValue))
                    } else {
                        onGetQuote(doubleValue)
                    }
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if PeraUserDefaults.shouldUseLocalCurrencyInSwap ?? false {
                        receivingText = fiatFormat(with: 0.0)
                        receivingTextInSecondaryCurrency = SwapSharedViewModel.defaultAmountValue
                        payingText = fiatFormat(with: 0.0)
                        payingTextInSecondaryCurrency = SwapSharedViewModel.defaultAmountValue
                    } else {
                        receivingText = .empty
                        receivingTextInSecondaryCurrency = fiatFormat(with: 0.0)
                        payingText = .empty
                        payingTextInSecondaryCurrency = fiatFormat(with: 0.0)
                    }
                }
            }
        }
        debounceWorkItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: task)
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

        let value = filtered.numericValue()
        guard value > 0 else { return filtered }

        if PeraUserDefaults.shouldUseLocalCurrencyInSwap ?? false {
            return fiatFormat(with: value)
        } else {
            return Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 8).string(for: value) ?? filtered
        }
    }
    
}

// MARK: - Computed Properties
extension SwapSharedViewModel {
    var shouldShowSwapButton: Bool {
        if isBalanceNotSufficient || isLoadingPayAmount || isLoadingReceiveAmount { return false }
        if PeraUserDefaults.shouldUseLocalCurrencyInSwap ?? false {
            let paying = payingTextInSecondaryCurrency.numericValue()
            let receiving = receivingTextInSecondaryCurrency.numericValue()
            return paying > 0 && receiving > 0
        } else {
            let paying = payingText.numericValue()
            let receiving = receivingText.numericValue()
            return paying > 0 && receiving > 0
        }
    }

    var slippageTolerance: String {
        guard
            let slippageTolerance = selectedQuote?.slippage,
            slippageTolerance > 0
        else {
            return Formatter.percentageFormatter.string(from: 0) ?? .empty
        }
        return Formatter.percentageWith(fraction: 10).string(from: NSDecimalNumber(decimal: slippageTolerance)) ?? Formatter.percentageFormatter.string(from: 0)!
    }
    
    var priceImpact: String {
        guard
            let priceImpact = selectedQuote?.priceImpact,
            priceImpact > 0
        else {
            return Formatter.percentageFormatter.string(from: 0)!
        }
        return Formatter.percentageWith(fraction: 10).string(from: NSDecimalNumber(decimal: priceImpact)) ?? Formatter.percentageFormatter.string(from: 0)!
    }
    
    var price: String {
        guard
            let price = selectedQuote?.price,
            let assetOut = selectedQuote?.assetOut?.unitName,
            let assetIn = selectedQuote?.assetIn?.unitName
        else {
            return "-"
        }
        
        let priceText = "\(NSDecimalNumber(decimal: price).stringValue) \(assetOut)"
        return String(format: String(localized: "swap-confirm-price-info"), priceText, assetIn)
    }
    
    var providerRate: String {
        guard
            let price = selectedQuote?.price,
            let assetOut = selectedQuote?.assetOut?.unitName,
            let assetIn = selectedQuote?.assetIn?.unitName
        else {
            return "-"
        }
        
        guard let rate = Formatter.decimalFormatter(maximumFractionDigits: 3).string(from: NSDecimalNumber(decimal: price)) else {
            return "-"
        }
        
        
        return "1 \(assetIn) ≈ \(rate) \(assetOut)"
    }
    
    var minimumReceived: String {
        guard
            let amountOutWithSlippage = selectedQuote?.amountOutWithSlippage,
            let assetOutUnitName = selectedQuote?.assetOut?.unitName,
            let decimals = selectedQuote?.assetOut?.decimals
        else {
            return "-"
        }
        
        let value = Decimal(amountOutWithSlippage) / pow(10, decimals)
        return "\(value) \(assetOutUnitName)"
    }
    
    var peraFee: String {
        guard
            let peraFee = selectedQuote?.peraFee,
            let decimals = selectedQuote?.assetOut?.decimals
        else {
            return "-"
        }
        
        let value = Decimal(peraFee) / pow(10, decimals)
        
        let currencyFormatter = CurrencyFormatter()
        currencyFormatter.formattingContext = .listItem
        currencyFormatter.currency = AlgoLocalCurrency()
        
        return currencyFormatter.format(value) ?? "-"
    }
    
    var exchangeFee: String {
        guard
            let exchangeFee = selectedQuote?.exchangeFee,
            let decimals = selectedQuote?.assetOut?.decimals
        else {
            return "-"
        }
        
        let value = Decimal(exchangeFee) / pow(10, decimals)
        
        let currencyFormatter = CurrencyFormatter()
        currencyFormatter.formattingContext = .listItem
        currencyFormatter.currency = AlgoLocalCurrency()
        
        return currencyFormatter.format(value) ?? "-"
    }
    
    var activeProvider: SwapProviderV2? {
        switch selectedProvider {
        case .auto:
            let bestProviderId = quoteList?.first?.provider?.rawValue
            return availableProviders?.first(where: { $0.name == bestProviderId })
        case .provider(let providerId):
            return availableProviders?.first(where: { $0.name == providerId })
        }
    }
}

// MARK: - Exchange methods
extension SwapSharedViewModel {
    func fiatValue(fromAlgo amount: Double) -> Double {
        guard let currencyFiatValue = try? currency.fiatValue?.unwrap() else {
            return 0
        }
        let exchanger = CurrencyExchanger(currency: currencyFiatValue)
        
        guard let fiatAmount = try? exchanger.exchangeAlgo(amount: Decimal(amount)) else {
            return 0
        }
        
        return fiatAmount.doubleValue
    }
    
    private func fiatValue(fromUSDC amount: Double) -> Double {
        guard let currencyFiatValue = try? currency.fiatValue?.unwrap() else {
            return 0
        }
        let exchanger = CurrencyExchanger(currency: currencyFiatValue)
        
        guard let fiatAmount = try? exchanger.exchange(amount: Decimal(amount)) else {
            return 0
        }
        
        return fiatAmount.doubleValue
    }
    
    private func fiatValue(fromAsset asset: Asset, with amount: Double) -> Double {
        guard
            let currencyFiatValue = try? currency.fiatValue?.unwrap(),
            let fiatAmount = try? {
                let exchanger = CurrencyExchanger(currency: currencyFiatValue)
                return asset.isAlgo
                ? try exchanger.exchangeAlgo(amount: Decimal(amount))
                : try exchanger.exchange(asset, amount: Decimal(amount))
            }()
        else {
            return 0
        }
        return fiatAmount.doubleValue
    }
    
    func fiatValueText(fromAlgo amount: Double) -> String {
        fiatFormat(with: fiatValue(fromAlgo: amount))
    }
    
    func fiatValueText(fromUSDC amount: Double) -> String {
        fiatFormat(with: fiatValue(fromUSDC: amount))
    }
    
    func fiatValueText(fromAsset asset: Asset, with amount: Double) -> String {
        fiatFormat(with: fiatValue(fromAsset: asset, with: amount))
    }
    
    func fiatFormat(with amount: Double) -> String {
        guard let currencyFiatValue = try? currency.fiatValue?.unwrap() else {
            return .empty
        }
        
        let currencyFormatter = CurrencyFormatter()
        currencyFormatter.currency = currencyFiatValue
        return currencyFormatter.format(amount) ?? .empty
    }
    
    private func algoValue(fromFiat amount: Double) -> Double {
        guard let currencyFiatValue = try? currency.fiatValue?.unwrap() else {
            return 0
        }
        let exchanger = CurrencyExchanger(currency: currencyFiatValue)
        
        guard let algoAmount = try? exchanger.exchangeFiat(amount: Decimal(amount)) else {
            return 0
        }
        return algoAmount.doubleValue
    }
    
    func algoValueText(fromFiat amount: Double) -> String {
        algoFormat(with: algoValue(fromFiat: amount))
    }
    
    func algoFormat(with amount: Double) -> String {
        guard let currencyAlgoValue = try? currency.algoValue?.unwrap() else {
            return .empty
        }
        
        let currencyFormatter = CurrencyFormatter()
        currencyFormatter.currency = currencyAlgoValue
        return currencyFormatter.format(amount) ?? .empty
    }
}

// MARK: - Models

enum PercentageValue: CaseIterable, Equatable, Hashable {
    case custom(value: Double)
    case p25, p50, p75, max
    
    var title: String {
        switch self {
        case .custom: "Custom"
        case .p25: "25%"
        case .p50: "50%"
        case .p75: "75%"
        case .max: "MAX"
        }
    }
    
    var value: Double {
        switch self {
        case .custom(value: let value): value
        case .p25: 0.25
        case .p50: 0.5
        case .p75: 0.75
        case .max: 1
        }
    }
    
    static var allCases: [PercentageValue] {
        [.p25, .p50, .p75, .max]
    }
}

enum SlippageValue: Equatable, Hashable {
    case custom(value: Double)
    case c05, c1, c2, c5
    
    var title: String {
        switch self {
        case .custom: "Custom"
        case .c05: "0.5%"
        case .c1: "1%"
        case .c2: "2%"
        case .c5: "5%"
        }
    }
    
    var value: Double {
        switch self {
        case .custom(value: let value): value
        case .c05: 0.005
        case .c1: 0.01
        case .c2: 0.02
        case .c5: 0.05
        }
    }
    
    static var allDefaultCases: [SlippageValue] {
        [.c05, .c1, .c2, .c5]
    }
    
    static var allCases: [SlippageValue] {
        [.custom(value: 0), .c05, .c1, .c2, .c5]
    }
    
    static func == (lhs: SlippageValue, rhs: SlippageValue) -> Bool {
        switch (lhs, rhs) {
        case (.custom, .custom),
            (.c05, .c05),
            (.c1, .c1),
            (.c2, .c2),
            (.c5, .c5):
            return true
        default:
            return false
        }
    }
}

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
