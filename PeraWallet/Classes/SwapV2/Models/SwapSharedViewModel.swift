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
    
    var quote: SwapQuote?
    
    var shouldShowSwapButton: Bool {
        let paying = Double(payingText?.replacingOccurrences(of: ",", with: ".") ?? "") ?? 0
        let receiving = Double(receivingText?.replacingOccurrences(of: ",", with: ".") ?? "") ?? 0
        return paying > 0 && receiving > 0
    }
    
    var slippageTolerance: String {
        guard
            let slippageTolerance = quote?.slippage,
            slippageTolerance > 0
        else {
            return Formatter.percentageFormatter.string(from: 0)!
        }
        return Formatter.percentageWith(fraction: 10).string(from: NSDecimalNumber(decimal: slippageTolerance)) ?? Formatter.percentageFormatter.string(from: 0)!
    }
    
    var priceImpact: String {
        guard
            let priceImpact = quote?.priceImpact,
            priceImpact > 0
        else {
            return Formatter.percentageFormatter.string(from: 0)!
        }
        return Formatter.percentageWith(fraction: 10).string(from: NSDecimalNumber(decimal: priceImpact)) ?? Formatter.percentageFormatter.string(from: 0)!
    }
    
    var price: String {
        guard
            let price = quote?.price,
            let assetOut = quote?.assetOut?.unitName,
            let assetIn = quote?.assetIn?.unitName
        else {
            return "-"
        }
        
        let priceText = "\(NSDecimalNumber(decimal: price).stringValue) \(assetOut)"
        return String(format: String(localized: "swap-confirm-price-info"), priceText, assetIn)
    }
    
    @Published var provider: Provider = Provider(
        name: "Vestige.fi",
        iconName: "icon-shield-16",
        exchangeRate: "1 ALGO ≈ 0.17 USDC"
    )
    
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
