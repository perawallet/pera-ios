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

//   PortfolioViewModel.swift

import Foundation
import MacaroonUIKit

protocol PortfolioViewModel: ViewModel {
    var currencyFormatter: CurrencyFormatter? { get }
}

extension PortfolioViewModel {
    func format(
        portfolioValue: PortfolioValue?,
        currencyValue: RemoteCurrencyValue?,
        isAmountHidden: Bool,
        addApproximatelyEqualChar: Bool = false,
        in context: CurrencyFormattingContext
    ) -> String? {
        guard
            let portfolioValue = portfolioValue,
            let currencyValue = currencyValue
        else {
            return nil
        }

        do {
            let portfolio = try portfolioValue.unwrap()
            let rawCurrency = try currencyValue.unwrap()

            let exchanger = CurrencyExchanger(currency: rawCurrency)
            let amount = try exchanger.exchange(portfolio)

            let formatter = currencyFormatter ?? CurrencyFormatter()
            formatter.formattingContext = context
            formatter.currency =  rawCurrency
            formatter.isValueHidden = isAmountHidden
            guard
                addApproximatelyEqualChar,
                let string = formatter.format(amount)
            else {
                return formatter.format(amount)
            }
           return "≈ " + string
        } catch {
            return nil
        }
    }
    
    func format(
        selectedPointValue: Double,
        currencyValue: RemoteCurrencyValue?,
        isSecondaryValue: Bool,
        isAmountHidden: Bool,
        addApproximatelyEqualChar: Bool = false,
        in context: CurrencyFormattingContext
    ) -> String? {
        guard let currencyValue else { return nil }

        do {
            let rawCurrency = try currencyValue.unwrap()
            
            var amount = Decimal(selectedPointValue)
            if isSecondaryValue {
                amount = try {
                    guard !rawCurrency.isAlgo else { return Decimal(selectedPointValue) }
                    let exchanger = CurrencyExchanger(currency: rawCurrency)
                    return try exchanger.exchange(amount: Decimal(selectedPointValue))
                }()
            }

            let formatter = currencyFormatter ?? CurrencyFormatter()
            formatter.formattingContext = context
            formatter.currency =  rawCurrency
            formatter.isValueHidden = isAmountHidden

            guard
                addApproximatelyEqualChar,
                let string = formatter.format(amount)
            else {
                return formatter.format(amount)
            }
           return "≈ " + string
        } catch {
            return nil
        }
    }
}
