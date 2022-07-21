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

//   AlgoAmountViewModel.swift

import Foundation
import MacaroonUIKit

struct AlgoAmountViewModel: PrimaryTitleViewModel {
    var title: EditText?
    var icon: Image?
    var subtitle: EditText?

    private(set) var valueInUSD: Decimal = 0

    init(
        _ item: AlgoAssetItem
    ) {
        bindTitle(item)
        bindIcon()
        bindSubtitle(item)
    }
}

extension AlgoAmountViewModel {
    private mutating func bindTitle(
        _ item: AlgoAssetItem
    ) {
        guard let algoAmount = item.amount else {
            title = nil
            return
        }

        let formatter = item.currencyFormatter
        formatter.formattingContext = item.currencyFormattingContext ?? .listItem
        formatter.currency = AlgoLocalCurrency()

        if let aTitle = formatter.format(algoAmount) {
            title = .attributedString(aTitle.bodyRegular(alignment: .right))
        } else {
            title = nil
        }
    }

    private mutating func bindIcon() {
        icon = nil
    }

    private mutating func bindSubtitle(
        _ item: AlgoAssetItem
    ) {
        do {
            guard
                let algoAmount = item.amount,
                let fiatCurrencyValue = item.currency.fiatValue
            else {
                subtitle = nil
                valueInUSD = 0
                return
            }

            let fiatRawCurrency = try fiatCurrencyValue.unwrap()

            let exchanger = CurrencyExchanger(currency: fiatRawCurrency)
            let amount = try exchanger.exchangeAlgo(amount: algoAmount)

            let formatter = item.currencyFormatter
            formatter.formattingContext = item.currencyFormattingContext ?? .listItem
            formatter.currency = fiatRawCurrency

            if let aSubtitle = formatter.format(amount) {
                subtitle = .attributedString(aSubtitle.footnoteRegular(alignment: .right))
            } else {
                subtitle = nil
            }

            valueInUSD = fiatRawCurrency.algoToUSDValue ?? 0
        } catch {
            subtitle = nil
            valueInUSD = 0
        }
    }
}
