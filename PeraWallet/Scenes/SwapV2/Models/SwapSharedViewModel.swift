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
    
    @Published var payingText: String = defaultAmountValue
    @Published var payingTextInSecondaryCurrency: String = defaultAmountValue
    @Published var receivingText: String = defaultAmountValue
    @Published var receivingTextInSecondaryCurrency: String = defaultAmountValue
    
    @Published var swapConfirmationState: ConfirmSlideButtonState = .idle
    
    @Published var selectedNetwork: ALGAPI.Network
    
    @Published var slippageSelected: SlippageValue? = nil
    
    private var debounceWorkItem: DispatchWorkItem?
    
    static let defaultAmountValue = Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 1).string(for: Decimal(0))!
    
    let currency: CurrencyProvider
    
    // MARK: - Internal State
    var quoteList: [SwapQuote]?
    var availableProviders: [SwapProviderV2]?

    // MARK: - Init
    init(
        selectedAccount: Account,
        selectedAssetIn: AssetItem,
        selectedAssetOut: AssetItem,
        selectedNetwork: ALGAPI.Network,
        currency: CurrencyProvider
    ) {
        self.selectedAccount = selectedAccount
        self.selectedAssetIn = selectedAssetIn
        self.selectedAssetOut = selectedAssetOut
        self.selectedProvider = .auto
        self.selectedNetwork = selectedNetwork
        self.currency = currency
    }
    
    // MARK: - Helpers
    
    func switchAssets() {
        (selectedAssetIn, selectedAssetOut) = (selectedAssetOut, selectedAssetIn)
        (payingText, receivingText) = (receivingText, payingText)
        (payingTextInSecondaryCurrency, receivingTextInSecondaryCurrency) = (receivingTextInSecondaryCurrency, payingTextInSecondaryCurrency)
    }
    
    func confirmSwapModel() -> SwapConfirmViewModel {
        guard let activeProvider else {
            fatalError("Active provider should not be nil")
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
            receivingTextInSecondaryCurrency = algoFormat(with: valueOut.doubleValue)
        } else {
            receivingTextInSecondaryCurrency = fiatValueText(fromUSDC: valueOut.doubleValue)
        }
    }
    
    func updatePayingText(_ newValue: String, onGetQuote: @escaping (Double) -> Void) {
        debounceWorkItem?.cancel()

        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            let normalized = newValue
                .replacingOccurrences(of: "[^0-9,\\.]", with: "", options: .regularExpression)
                .replacingOccurrences(of: ",", with: ".")
            if let doubleValue = Double(normalized), doubleValue > 0 {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    isBalanceNotSufficient = doubleValue > NSDecimalNumber(decimal: selectedAssetIn.asset.decimalAmount).doubleValue
                    
                    
                    isLoadingReceiveAmount = true
                    
                    if PeraUserDefaults.shouldUseLocalCurrencyInSwap ?? false {
                        payingText = fiatFormat(with: doubleValue)
                        payingTextInSecondaryCurrency = algoValueText(fromFiat: doubleValue)
                      onGetQuote(algoValue(fromFiat: doubleValue))
                    } else {
                        payingText = Formatter
                            .decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 8)
                            .string(for: doubleValue) ?? .empty
                        payingTextInSecondaryCurrency = fiatValueText(fromAlgo: doubleValue)
                        onGetQuote(doubleValue)
                    }
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    receivingText = Self.defaultAmountValue
                    receivingTextInSecondaryCurrency = Self.defaultAmountValue
                    payingText = Self.defaultAmountValue
                    payingTextInSecondaryCurrency = Self.defaultAmountValue
                }
            }
        }

        debounceWorkItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: task)
    }
}

// MARK: - Computed Properties
extension SwapSharedViewModel {
    var shouldShowSwapButton: Bool {
        if isBalanceNotSufficient { return false }
        if PeraUserDefaults.shouldUseLocalCurrencyInSwap ?? false {
            let paying = Double(
                payingTextInSecondaryCurrency
                    .replacingOccurrences(of: "[^0-9,\\.]", with: "", options: .regularExpression)
                    .replacingOccurrences(of: ",", with: ".")
            ) ?? 0
            let receiving = Double(
                receivingTextInSecondaryCurrency
                    .replacingOccurrences(of: "[^0-9,\\.]", with: "", options: .regularExpression)
                    .replacingOccurrences(of: ",", with: ".")
            ) ?? 0
            return paying > 0 && receiving > 0
        } else {
            let paying = Double(payingText.replacingOccurrences(of: ",", with: ".")) ?? 0
            let receiving = Double(receivingText.replacingOccurrences(of: ",", with: ".")) ?? 0
            return paying > 0 && receiving > 0
        }

    }
    
    var slippageTolerance: String {
        guard
            let slippageTolerance = selectedQuote?.slippage,
            slippageTolerance > 0
        else {
            return Formatter.percentageFormatter.string(from: 0)!
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
        
        guard let rate = Formatter.decimalFormatter(maximumFractionDigits: 3).string(from: NSDecimalNumber(decimal: (1 / price))) else {
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
        
        guard let fiatAmount = try? exchanger.exchangeAlgo(amount: amount.decimal) else {
            return 0
        }
        
        return fiatAmount.doubleValue
    }
    
    private func fiatValue(fromUSDC amount: Double) -> Double {
        guard let currencyFiatValue = try? currency.fiatValue?.unwrap() else {
            return 0
        }
        let exchanger = CurrencyExchanger(currency: currencyFiatValue)
        
        guard let fiatAmount = try? exchanger.exchange(amount: amount.decimal) else {
            return 0
        }
        
        return fiatAmount.doubleValue
    }
    
    private func fiatValue(fromAsset asset: Asset, with amount: Double) -> Double {
        guard let currencyFiatValue = try? currency.fiatValue?.unwrap() else {
            return 0
        }
        let exchanger = CurrencyExchanger(currency: currencyFiatValue)
        
        guard let fiatAmount = try? exchanger.exchange(asset, amount: amount.decimal) else {
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
        
        guard let algoAmount = try? exchanger.exchangeFiat(amount: amount.decimal) else {
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

enum SlippageValue: CaseIterable, Equatable {
    case custom, c05, c1, c2, c5
    
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
        case .custom: 0
        case .c05: 0.005
        case .c1: 0.01
        case .c2: 0.02
        case .c5: 0.05
        }
    }
}
