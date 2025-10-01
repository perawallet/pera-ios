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
    @Published var payingTextInUSD: String = defaultAmountValue
    @Published var receivingText: String = defaultAmountValue
    @Published var receivingTextInUSD: String = defaultAmountValue
    
    @Published var swapConfirmationState: ConfirmSlideButtonState = .idle
    
    @Published var selectedNetwork: ALGAPI.Network
    
    private var debounceWorkItem: DispatchWorkItem?
    
    static let defaultAmountValue = Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 1).string(for: Decimal(0))!
    
    // MARK: - Internal State
    var quoteList: [SwapQuote]?
    var availableProviders: [SwapProviderV2]?

    // MARK: - Init
    init(
        selectedAccount: Account,
        selectedAssetIn: AssetItem,
        selectedAssetOut: AssetItem,
        selectedNetwork: ALGAPI.Network
    ) {
        self.selectedAccount = selectedAccount
        self.selectedAssetIn = selectedAssetIn
        self.selectedAssetOut = selectedAssetOut
        self.selectedProvider = .auto
        self.selectedNetwork = selectedNetwork
    }
    
    // MARK: - Helpers
    
    func switchAssets() {
        (selectedAssetIn, selectedAssetOut) = (selectedAssetOut, selectedAssetIn)
        (payingText, receivingText) = (receivingText, payingText)
        (payingTextInUSD, receivingTextInUSD) = (receivingTextInUSD, payingTextInUSD)
    }
    
    func confirmSwapModel() -> SwapConfirmViewModel {
        guard let activeProvider else {
            fatalError("Active provider should not be nil")
        }
        
        return SwapConfirmViewModel(
            selectedAccount: selectedAccount,
            selectedAssetIn: selectedAssetIn,
            selectedAssetOut: selectedAssetOut,
            selectedAssetInAmount: payingText,
            selectedAssetOutAmount: receivingText,
            selectedAssetInAmountInUSD: payingTextInUSD,
            selectedAssetOutAmountInUSD: receivingTextInUSD,
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
        
        let amount = selectedQuote.amountOut ?? 0
        let decimals = selectedQuote.assetOut?.decimals ?? 0
        let value = Decimal(amount) / pow(10, decimals)
        
        receivingText = Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 8).string(for: value) ?? .empty
        
        receivingTextInUSD = "$" + (Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 2).string(for: selectedQuote.amountOutUSDValue) ?? .empty)
        
        payingTextInUSD = "$" + (Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 2).string(for: selectedQuote.amountOutUSDValue) ?? .empty)
    }
    
    func updatePayingText(_ newValue: String, onGetQuote: @escaping (Double) -> Void) {
        debounceWorkItem?.cancel()

        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            let normalized = newValue.replacingOccurrences(of: ",", with: ".")
            if let doubleValue = Double(normalized), doubleValue > 0 {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    isBalanceNotSufficient = doubleValue > NSDecimalNumber(decimal: selectedAssetIn.asset.decimalAmount).doubleValue
                    
                    payingText = Formatter
                        .decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 8)
                        .string(for: doubleValue) ?? .empty
                    isLoadingReceiveAmount = true
                    onGetQuote(doubleValue)
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    receivingText = .empty
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
        let paying = Double(payingText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let receiving = Double(receivingText.replacingOccurrences(of: ",", with: ".")) ?? 0
        return paying > 0 && receiving > 0
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
