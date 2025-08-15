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

//
//   AccountPortfolioViewModel.swift

import Foundation
import MacaroonUIKit
import pera_wallet_core

struct AccountPortfolioViewModel:
    PortfolioViewModel,
    Hashable {
    private(set) var primaryValue: TextProvider?
    private(set) var secondaryValue: TextProvider?
    private(set) var minimumBalanceTitle: TextProvider?
    private(set) var minimumBalanceValue: TextProvider?
    private(set) var selectedPointDateValue: TextProvider?

    private(set) var currencyFormatter: CurrencyFormatter?

    init(
        _ portfolioItem: AccountPortfolioItem,
        selectedPoint: ChartSelectedPointViewModel?
    ) {
        guard let selectedPoint else {
            bind(portfolioItem)
            return
        }
        bind(portfolioItem, selectedPoint: selectedPoint)
    }
}

extension AccountPortfolioViewModel {
    mutating func bind(
        _ portfolioItem: AccountPortfolioItem
    ) {
        self.currencyFormatter = portfolioItem.currencyFormatter

        bindPrimaryValue(portfolioItem)
        bindSecondaryValue(portfolioItem)
        bindMinimumBalance(portfolioItem)
    }
    
    mutating func bind(
        _ portfolioItem: AccountPortfolioItem,
        selectedPoint: ChartSelectedPointViewModel
    ) {
        self.currencyFormatter = portfolioItem.currencyFormatter

        bindPrimaryValue(portfolioItem, selectedPoint: selectedPoint)
        bindSecondaryValue(portfolioItem, selectedPoint: selectedPoint)
        bindSelectedPointDateValue(selectedPoint: selectedPoint)
    }
    
    mutating func bindPrimaryValue(
        _ portfolioItem: AccountPortfolioItem
    ) {
        let text = format(
            portfolioValue: portfolioItem.portfolioValue,
            currencyValue: portfolioItem.currency.primaryValue,
            isAmountHidden: portfolioItem.isAmountHidden,
            in: .standalone()
        ) ?? CurrencyConstanst.unavailable
        primaryValue = text.largeTitleMedium(
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
    }
    
    mutating func bindPrimaryValue(
        _ portfolioItem: AccountPortfolioItem,
        selectedPoint: ChartSelectedPointViewModel
    ) {
        let text = format(
            selectedPoint: selectedPoint,
            currencyValue: portfolioItem.currency.primaryValue,
            isAmountHidden: portfolioItem.isAmountHidden,
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
            isAmountHidden: portfolioItem.isAmountHidden,
            in: .standalone()
        ) ?? CurrencyConstanst.unavailable
        secondaryValue = text.bodyMedium(
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
    }
    
    mutating func bindSecondaryValue(
        _ portfolioItem: AccountPortfolioItem,
        selectedPoint: ChartSelectedPointViewModel
    ) {
        let text = format(
            selectedPoint: selectedPoint,
            currencyValue: portfolioItem.currency.secondaryValue,
            isAmountHidden: portfolioItem.isAmountHidden,
            addApproximatelyEqualChar: true,
            in: .standalone()
        ) ?? CurrencyConstanst.unavailable
        secondaryValue = text.bodyMedium(
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
    }

    mutating func bindMinimumBalance(
        _ portfolioItem: AccountPortfolioItem
    ) {
        bindMinimumBalanceTitle(portfolioItem)
        bindMinimumBalanceValue(portfolioItem)
    }

    mutating func bindMinimumBalanceTitle(
        _ portfolioItem: AccountPortfolioItem
    ) {
        minimumBalanceTitle =
            String(localized: "min-balance-title")
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindMinimumBalanceValue(
        _ portfolioItem: AccountPortfolioItem
    ) {
        guard let minimumBalance = portfolioItem.minimumBalance else {
            assertionFailure("minimumBalance should be set.")
            return
        }

        let formatter = portfolioItem.currencyFormatter
        formatter.formattingContext = .standalone()
        formatter.currency = AlgoLocalCurrency()
        let unformattedMinimumBalance = minimumBalance.toAlgos
        let formattedMinimumBalance = formatter.format(unformattedMinimumBalance)

        let text = "\(formattedMinimumBalance ?? "-")"

        minimumBalanceValue = text.footnoteRegular(lineBreakMode: .byTruncatingTail)
    }
    
    mutating func bindSelectedPointDateValue(
        selectedPoint: ChartSelectedPointViewModel
    ) {
        selectedPointDateValue = selectedPoint.dateValue.bodyMedium(
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
