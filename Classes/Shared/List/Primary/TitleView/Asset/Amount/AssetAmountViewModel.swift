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
    ViewModel,
    Hashable {
    var primaryTitle: TextProvider?
    var primaryTitleAccessory: Image?
    var secondaryTitle: TextProvider?

    private(set) var valueInUSD: Decimal = 0

    init(
        _ item: AssetItem
    ) {
        bindPrimaryTitle(item)
        bindPrimaryTitleAccessory()
        bindSecondaryTitle(item)
    }
}

extension AssetAmountViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(primaryTitle?.string)
        hasher.combine(secondaryTitle?.string)
    }

    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.primaryTitle?.string == rhs.primaryTitle?.string &&
            lhs.secondaryTitle?.string == rhs.secondaryTitle?.string
    }
}

extension AssetAmountViewModel {
    mutating func bindPrimaryTitle(
        _ item: AssetItem
    ) {
        let asset = item.asset

        let formatter = item.currencyFormatter
        formatter.formattingContext = item.currencyFormattingContext ?? .listItem
        if asset.isAlgo {
            formatter.currency = AlgoLocalCurrency()
        } else {
            formatter.currency = nil
        }


        let text = formatter.format(asset.decimalAmount)
        primaryTitle = text?.bodyRegular(
            alignment: .right,
            lineBreakMode: .byTruncatingTail
        )
    }

    mutating func bindPrimaryTitleAccessory() {
        primaryTitleAccessory = nil
    }

    mutating func bindSecondaryTitle(
        _ item: AssetItem
    ) {
        let asset = item.asset
        valueInUSD = asset.totalUSDValue ?? 0
        let formatter = item.currencyFormatter
        formatter.formattingContext = item.currencyFormattingContext ?? .listItem

        do {
            let exchanger: CurrencyExchanger
            if asset.isAlgo {
                guard let fiatRawCurrency = try item.currency.fiatValue?.unwrap() else {
                    secondaryTitle = nil
                    valueInUSD = 0
                    return
                }

                exchanger = CurrencyExchanger(currency: fiatRawCurrency)
                valueInUSD = fiatRawCurrency.algoToUSDValue ?? 0
            } else {
                guard let currencyValue = item.currency.primaryValue else {
                    secondaryTitle = nil
                    valueInUSD = 0
                    return
                }

                let rawCurrency = try currencyValue.unwrap()
                exchanger = CurrencyExchanger(currency: rawCurrency)

                formatter.currency = rawCurrency
            }


            let amount: Decimal
            if asset.isAlgo {
                amount = try exchanger.exchangeAlgo(amount: asset.decimalAmount)
            } else {
                amount = try exchanger.exchange(asset)
            }


            let text = formatter.format(amount)
            secondaryTitle = text?.footnoteRegular(
                alignment: .right,
                lineBreakMode: .byTruncatingTail
            )
        } catch {
            secondaryTitle = nil
            valueInUSD = 0
        }
    }
}
