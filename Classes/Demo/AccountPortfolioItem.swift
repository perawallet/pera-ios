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

//   AccountPortfolioItem.swift

import Foundation

final class AccountPortfolioItem {
    let accountValue: AccountHandle
    let portfolioValue: PortfolioValue
    let currency: CurrencyProvider
    let currencyFormatter: CurrencyFormatter
    let minimumBalance: UInt64?
    let isAmountHidden: Bool

    init(
        accountValue: AccountHandle,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter,
        minimumBalance: UInt64? = nil,
        isAmountHidden: Bool
    ) {
        self.accountValue = accountValue
        self.portfolioValue = PortfolioValue(accountValue: accountValue)
        self.currency = currency
        self.currencyFormatter = currencyFormatter
        self.minimumBalance = minimumBalance
        self.isAmountHidden = isAmountHidden
    }
}
