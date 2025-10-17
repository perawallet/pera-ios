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

//   AssetItem.swift

public final class AssetItem {
    public var asset: Asset
    public let currency: CurrencyProvider
    public let currencyFormatter: CurrencyFormatter
    public let currencyFormattingContext: CurrencyFormattingContext?
    public let isAmountHidden: Bool

    public init(
        asset: Asset,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter,
        currencyFormattingContext: CurrencyFormattingContext? = nil,
        isAmountHidden: Bool
    ) {
        self.asset = asset
        self.currency = currency
        self.currencyFormatter = currencyFormatter
        self.currencyFormattingContext = currencyFormattingContext
        self.isAmountHidden = isAmountHidden
    }
}

public extension AssetItem {
    var balance: String? {
        let asset = asset
        
        let formatter = currencyFormatter
        var formattingRules = CurrencyFormattingContextRules()
        formattingRules.minimumFractionDigits = 0
        formattingRules.maximumFractionDigits = 7
        
        formatter.formattingContext = .standalone(constraints: formattingRules)
        formatter.isValueHidden = isAmountHidden
        if asset.isAlgo {
            formatter.currency = AlgoLocalCurrency()
            return formatter.format(asset.decimalAmount)
        } else {
            formatter.currency = nil
            return formatter.format(asset.decimalAmount)?.appending(" \(asset.naming.unitName ?? asset.naming.displayNames.primaryName)")
        }
    }
}
