// Copyright 2025 Pera Wallet, LDA

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

class SwapSharedViewModel: ObservableObject {
    @Published var selectedAccount: Account
    @Published var selectedAssetIn: AssetItem
    @Published var selectedAssetOut: AssetItem
    var quote: SwapQuote?
    
    var slippageTolerance: String {
        guard
            let slippageTolerance = quote?.slippage,
            slippageTolerance > 0
        else {
            return Formatter.percentageFormatter.string(from: 0)!
        }
        return Formatter.percentageWith(fraction: 10).string(from: NSDecimalNumber(decimal: slippageTolerance / 100)) ?? Formatter.percentageFormatter.string(from: 0)!
    }
    
    var priceImpact: String {
        guard
            let priceImpact = quote?.priceImpact,
            priceImpact > 0
        else {
            return Formatter.percentageFormatter.string(from: 0)!
        }
        return Formatter.percentageWith(fraction: 10).string(from: NSDecimalNumber(decimal: priceImpact / 100)) ?? Formatter.percentageFormatter.string(from: 0)!
    }
    
    
    
    @Published var provider: Provider = Provider(
        name: "Vestige.fi",
        iconName: "icon-shield-16",
        exchangeRate: "1 ALGO ≈ 0.17 USDC"
    )
    
    @Published var isPayingView: Bool = true
    @Published var payingText: String? = nil
    @Published var receivingText: String? = nil

    init(
        selectedAccount: Account,
        selectedAssetIn: AssetItem,
        selectedAssetOut: AssetItem
    ) {
        self.selectedAccount = selectedAccount
        self.selectedAssetIn = selectedAssetIn
        self.selectedAssetOut = selectedAssetOut
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
