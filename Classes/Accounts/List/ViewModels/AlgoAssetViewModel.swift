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

//
//  AlgoAssetViewModel.swift

import Foundation
import MacaroonUIKit

struct AlgoAssetViewModel: ViewModel {
    private(set) var amount: String?
    private(set) var valueInCurrency: String?
    private(set) var valueInUSD: Decimal = 0

    init(
        _ model: AlgoAssetItem
    ) {
        bind(model)
    }
}

extension AlgoAssetViewModel {
    mutating func bind(
        _ item: AlgoAssetItem
    ) {
        bindAmount(item)
        bindValue(item)
    }

    mutating func bindAmount(
        _ item: AlgoAssetItem
    ) {
        do {
            guard
                let algoAmount = item.amount,
                let algoCurrencyValue = item.currency.algoValue
            else {
                amount = nil
                return
            }

            let algoRawCurrency = try algoCurrencyValue.unwrap()

            let formatter = item.currencyFormatter
            formatter.formattingContext = .listItem
            formatter.currency = algoRawCurrency

            amount = formatter.format(algoAmount)
        } catch {
            amount = nil
        }
    }

    private mutating func bindValue(
        _ item: AlgoAssetItem
    ) {
        do {
            guard
                let algoAmount = item.amount,
                let fiatCurrencyValue = item.currency.fiatValue
            else {
                valueInCurrency = nil
                valueInUSD = 0
                return
            }

            let fiatRawCurrency = try fiatCurrencyValue.unwrap()

            let exchanger = CurrencyExchanger(currency: fiatRawCurrency)
            let amount = try exchanger.exchange(algo: algoAmount)

            let formatter = item.currencyFormatter
            formatter.formattingContext = .listItem
            formatter.currency = fiatRawCurrency

            valueInCurrency = formatter.format(amount)
            valueInUSD = fiatRawCurrency.algoToUSDValue ?? 0
        } catch {
            valueInCurrency = nil
            valueInUSD = 0
        }
    }
}
