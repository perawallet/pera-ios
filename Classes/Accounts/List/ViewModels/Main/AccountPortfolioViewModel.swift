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
//   AccountPortfolioViewModel.swift

import Foundation
import MacaroonUIKit

struct AccountPortfolioViewModel:
    PortfolioViewModel,
    PairedViewModel,
    Hashable {
    private(set) var title: TextProvider?
    private(set) var primaryValue: TextProvider?
    private(set) var secondaryValue: TextProvider?

    private(set) var currencyFormatter: CurrencyFormatter?

    init(
        _ portfolioItem: AccountPortfolioItem
    ) {
        bind(portfolioItem)
    }
}

extension AccountPortfolioViewModel {
    mutating func bind(
        _ portfolioItem: AccountPortfolioItem
    ) {
        self.currencyFormatter = portfolioItem.currencyFormatter

        bindTitle(portfolioItem)
        bindPrimaryValue(portfolioItem)
        bindSecondaryValue(portfolioItem)
    }
    
    mutating func bindTitle(
        _ portfolioItem: AccountPortfolioItem
    ) {
        title = "account-detail-portfolio-title"
            .localized
            .bodyRegular(
                alignment: .center,
                lineBreakMode: .byTruncatingTail
            )
    }
    
    mutating func bindPrimaryValue(
        _ portfolioItem: AccountPortfolioItem
    ) {
        let text = format(
            portfolioValue: portfolioItem.portfolioValue,
            currencyValue: portfolioItem.currency.primaryValue,
            in: .standalone()
        ) ?? CurrencyConstanst.unavailable
        primaryValue = text.largeTitleMedium(
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
    }

    mutating func bindSecondaryValue(
        _ portfolioItem: AccountPortfolioItem
    ) {
        let text = format(
            portfolioValue: portfolioItem.portfolioValue,
            currencyValue: portfolioItem.currency.secondaryValue,
            in: .standalone()
        ) ?? CurrencyConstanst.unavailable
        secondaryValue = "≈ \(text)".bodyMedium(
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
    }
}

extension AccountPortfolioViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(primaryValue?.string)
        hasher.combine(secondaryValue?.string)
    }
    
    static func == (
        lhs: AccountPortfolioViewModel,
        rhs: AccountPortfolioViewModel
    ) -> Bool {
        return
            lhs.primaryValue?.string == rhs.primaryValue?.string &&
            lhs.secondaryValue?.string == rhs.secondaryValue?.string
    }
}
