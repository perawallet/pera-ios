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
    private(set) var currencyAmount: String?
    private(set) var currencyDecimal: Decimal?

    init(account: Account, currency: Currency?) {
        bindAmount(from: account)

        if let algoCurrency = currency as? AlgoCurrency {
            bindCurrencyAmount(from: account, with: algoCurrency.currency, isAlgoCurrency: true)
        } else {
            bindCurrencyAmount(from: account, with: currency, isAlgoCurrency: false)
        }
    }
}

extension AlgoAssetViewModel {
    private mutating func bindAmount(from account: Account) {
        amount = account.amount.toAlgos.toFullAlgosStringForLabel
    }

    private mutating func bindCurrencyAmount(
        from account: Account,
        with currency: Currency?,
        isAlgoCurrency: Bool = false
    ) {
        guard let currency = currency,
              let currencyPriceValue = currency.priceValue else {
            return
        }

        let totalAmount = account.amount.toAlgos * currencyPriceValue
        currencyAmount = totalAmount.abbreviatedCurrencyStringForLabel(with: currency.symbol)

        if isAlgoCurrency {
            currencyDecimal = account.amount.toAlgos
        } else {
            currencyDecimal = totalAmount
        }
    }
}
