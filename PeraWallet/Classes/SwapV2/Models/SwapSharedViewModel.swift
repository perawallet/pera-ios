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
    @Published var selectedAccount: Account
    @Published var selectedAssetIn: AssetItem
    @Published var selectedAssetOut: AssetItem
    @Published var isLoadingQuote: Bool = false
    @Published var selectedQuote: SwapQuote?
    
    var quoteList: [SwapQuote]?
    var availableProviders: [SwapProviderV2]?
    
    var shouldShowSwapButton: Bool {
        let paying = Double(payingText?.replacingOccurrences(of: ",", with: ".") ?? "") ?? 0
        let receiving = Double(receivingText?.replacingOccurrences(of: ",", with: ".") ?? "") ?? 0
        return paying > 0 && receiving > 0
    }
    
    var selectedProvider: SwapProviderV2? {
        guard let selectedQuote = selectedQuote else { return nil }
        return availableProviders?.first { $0.name == selectedQuote.provider?.rawValue }
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
            let assetOutDecimals = selectedQuote?.assetOut?.decimals
        else {
            return "-"
        }
        
        let value = Decimal(amountOutWithSlippage) / pow(10, assetOutDecimals)
        return "\(value) \(assetOutUnitName)"
    }
    
    @Published var isPayingView: Bool = true
    @Published var payingText: String? = nil
    @Published var receivingText: String? = nil
    
    private var cancellables = Set<AnyCancellable>()

    init(
        selectedAccount: Account,
        selectedAssetIn: AssetItem,
        selectedAssetOut: AssetItem
    ) {
        self.selectedAccount = selectedAccount
        self.selectedAssetIn = selectedAssetIn
        self.selectedAssetOut = selectedAssetOut
        
        $receivingText
            .sink { newValue in
                // Your logic here
                print("receivingText changed:", newValue ?? "nil")
            }
            .store(in: &cancellables)
    }
    
    func switchAssets() {
        let temp = selectedAssetIn
        selectedAssetIn = selectedAssetOut
        selectedAssetOut = temp
        let tempText = payingText
        payingText = receivingText
        receivingText = tempText
    }
    
    func confirmSwapModel() -> SwapConfirmViewModel {
        guard let payingText, let receivingText, let selectedProvider else {
            fatalError("Shouldn't be nil")
        }
        return SwapConfirmViewModel(selectedAccount: selectedAccount, selectedAssetIn: selectedAssetIn, selectedAssetOut: selectedAssetOut, selectedAssetInAmount: payingText, selectedAssetOutAmount: receivingText, price: price, provider: selectedProvider, slippageTolerance: slippageTolerance, priceImpact: priceImpact, minimumReceived: minimumReceived, exchangeFee: "", peraFee: "")
    }
    
    func selectProvider(_ providerId: String) {
        guard let quoteList else { return }
        guard providerId != "auto" else {
            selectedQuote = quoteList.first
            return
        }
        selectedQuote = quoteList.first { $0.provider?.rawValue == providerId}
    }
}

struct Provider {
    let name: String
    let iconName: String
    let exchangeRate: String

    var icon: Image {
        Image(iconName)
    }
}
