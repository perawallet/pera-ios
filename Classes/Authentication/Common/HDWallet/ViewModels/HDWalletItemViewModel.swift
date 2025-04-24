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

//
//   HDWalletItemViewModel.swift

import Foundation
import MacaroonUIKit

struct HDWalletItemViewModel:
    ViewModel,
    Hashable {
    private(set) var title: TextProvider?
    private(set) var subtitle: TextProvider?
    private(set) var mainCurrency: TextProvider?
    private(set) var secondaryCurrency: TextProvider?

    init(
        walletName: String,
        accountsCount: Int,
        mainCurrency: Double,
        secondaryCurrency: Double,
        currencyFormatter: CurrencyFormatter,
        currencyProvider: CurrencyProvider
    ) {
        bindTitle(walletName)
        bindSubtitle(accountsCount)
        bindMainCurrency(
            mainCurrency,
            currencyFormatter: currencyFormatter,
            currencyProvider: currencyProvider
        )
        bindSecondaryCurrency(
            secondaryCurrency,
            currencyFormatter: currencyFormatter,
            currencyProvider: currencyProvider
        )
    }
}

extension HDWalletItemViewModel {
    private mutating func bindTitle(
        _ walletName: String
    ) {
        title = walletName
    }
    
    private mutating func bindSubtitle(
        _ accountsCount: Int
    ) {
        subtitle = String(format: String(localized: "account-count"), accountsCount)
    }
    
    private mutating func bindMainCurrency(
        _ mainCurrency: Double,
        currencyFormatter: CurrencyFormatter,
        currencyProvider: CurrencyProvider
    ) {
        if let currency = try? currencyProvider.primaryValue?.unwrap() {
            currencyFormatter.currency = currency
        } else {
            currencyFormatter.currency = AlgoLocalCurrency()
        }
        
        currencyFormatter.formattingContext = .listItem
        self.mainCurrency = currencyFormatter.format(mainCurrency)
    }
    
    private mutating func bindSecondaryCurrency(
        _ secondaryCurrency: Double,
        currencyFormatter: CurrencyFormatter,
        currencyProvider: CurrencyProvider
    ) {
        guard let currency = try? currencyProvider.secondaryValue?.unwrap() else {
            self.secondaryCurrency = nil
            return
        }
        currencyFormatter.currency = currency
        currencyFormatter.formattingContext = .listItem
        self.secondaryCurrency = currencyFormatter.format(secondaryCurrency)
    }
}

extension HDWalletItemViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(title?.string)
        hasher.combine(subtitle?.string)
        hasher.combine(mainCurrency?.string)
        hasher.combine(secondaryCurrency?.string)
    }

    static func == (
        lhs: HDWalletItemViewModel,
        rhs: HDWalletItemViewModel
    ) -> Bool {
        return lhs.title?.string == rhs.title?.string
        && lhs.subtitle?.string == rhs.subtitle?.string
        && lhs.mainCurrency?.string == rhs.mainCurrency?.string
        && lhs.secondaryCurrency?.string == rhs.secondaryCurrency?.string
    }
}
