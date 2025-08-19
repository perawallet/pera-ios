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

//   AccountDescendingTotalPortfolioValueAlgorithm.swift

import Foundation

public struct AccountDescendingTotalPortfolioValueAlgorithm: AccountSortingAlgorithm {
    public let id: String
    public let name: String
    public let isCustom: Bool
    public let currency: CurrencyProvider

    public init(
        currency: CurrencyProvider
    ) {
        self.id = "cache.value.accountDescendingTotalPortfolioValueAlgorithm"
        self.name = String(localized: "title-highest-value-to-lowest")
        self.isCustom = false
        self.currency = currency
    }
}

extension AccountDescendingTotalPortfolioValueAlgorithm {
    public func getFormula(
        account: AccountHandle,
        otherAccount: AccountHandle
    ) -> Bool {
        guard let currencyValue = currency.primaryValue else {
            return false
        }

        do {
            let rawCurrency = try currencyValue.unwrap()
            let exchanger = CurrencyExchanger(currency: rawCurrency)
            let accountPortfolio = Portfolio(account: account.value)
            let accountAmount = try exchanger.exchange(accountPortfolio)
            let otherAccountPortfolio = Portfolio(account: otherAccount.value)
            let otherAccountAmount = try exchanger.exchange(otherAccountPortfolio)

            if accountAmount != otherAccountAmount {
                return accountAmount > otherAccountAmount
            }

            return account.value.address > otherAccount.value.address
        } catch {
            return account.value.address > otherAccount.value.address
        }
    }
}
