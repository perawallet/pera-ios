// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AssetAmountViewModel.swift

import Foundation
import MacaroonUIKit

struct AssetAmountViewModel:
    ALGAssetAmountViewModel,
    Hashable {
    var title: EditText?
    var icon: Image?
    var subtitle: EditText?

    private(set) var valueInUSD: Decimal = 0

    init(
        _ item: AssetItem
    ) {
        bindTitle(item)
        bindIcon()
        bindSubtitle(item)
    }
}

extension AssetAmountViewModel {
    private mutating func bindTitle(
        _ item: AssetItem
    ) {
        let asset = item.asset

        let formatter = item.currencyFormatter
        formatter.formattingContext = item.currencyFormattingContext ?? .listItem
        formatter.currency = nil

        if let aTitle = formatter.format(asset.decimalAmount) {
            title = .attributedString(aTitle.bodyRegular(alignment: .right))
        } else {
            title = nil
        }
    }

    private mutating func bindIcon() {
        icon = nil
    }

    private mutating func bindSubtitle(
        _ item: AssetItem
    ) {
        let asset = item.asset

        valueInUSD = asset.totalUSDValue ?? 0

        guard let currencyValue = item.currency.primaryValue else {
            subtitle = nil
            return
        }

        do {
            let rawCurrency = try currencyValue.unwrap()

            let exchanger = CurrencyExchanger(currency: rawCurrency)
            let amount = try exchanger.exchange(asset)

            let formatter = item.currencyFormatter
            formatter.formattingContext = item.currencyFormattingContext ?? .listItem
            formatter.currency = rawCurrency

            if let aSubtitle = formatter.format(amount) {
                subtitle = .attributedString(aSubtitle.footnoteRegular(alignment: .right))
            } else {
                subtitle = nil
            }
        } catch {
            subtitle = nil
        }
    }
}
