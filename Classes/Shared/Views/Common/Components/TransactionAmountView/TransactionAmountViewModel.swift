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
//   TransactionAmountViewModel.swift

import MacaroonUIKit
import UIKit

struct TransactionAmountViewModel: Hashable {
    private(set) var signLabelText: EditText?
    private(set) var signLabelColor: UIColor?
    private(set) var amountLabelText: EditText?
    private(set) var amountLabelColor: UIColor?

    init(
        _ mode: TransactionAmountView.Mode,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter,
        showAbbreviation: Bool = false
    ) {
        bindMode(
            mode,
            currency: currency,
            currencyFormatter: currencyFormatter,
            showAbbreviation: showAbbreviation
        )
    }
}

extension TransactionAmountViewModel {
    private mutating func bindMode(
        _ mode: TransactionAmountView.Mode,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter,
        showAbbreviation: Bool
    ) {
        switch mode {
        case let .normal(amount, isAlgos, assetFraction, assetSymbol, _):
            signLabelText = nil
            bindAmount(
                amount,
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: showAbbreviation,
                with: assetFraction,
                isAlgos: isAlgos,
                assetSymbol: assetSymbol
            )
            amountLabelColor = AppColors.Components.Text.main.uiColor
        case let .positive(amount, isAlgos, assetFraction, assetSymbol, _):
            signLabelText = "+"
            signLabelColor = AppColors.Shared.Helpers.positive.uiColor
            bindAmount(
                amount,
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: showAbbreviation,
                with: assetFraction,
                isAlgos: isAlgos,
                assetSymbol: assetSymbol
            )
            amountLabelColor = AppColors.Shared.Helpers.positive.uiColor
        case let .negative(amount, isAlgos, assetFraction, assetSymbol, _):
            signLabelText = "-"
            signLabelColor = AppColors.Shared.Helpers.negative.uiColor
            bindAmount(
                amount,
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: showAbbreviation,
                with: assetFraction,
                isAlgos: isAlgos,
                assetSymbol: assetSymbol
            )
            amountLabelColor = AppColors.Shared.Helpers.negative.uiColor
        }
    }

    private mutating func bindAmount(
        _ amount: Decimal,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter,
        showAbbreviation: Bool,
        with assetFraction: Int?,
        isAlgos: Bool,
        assetSymbol: String? = nil
    ) {
        if isAlgos {
            do {
                guard let algoRawCurrency = try currency.algoRawCurrency else {
                    amountLabelText = nil
                    return
                }

                currencyFormatter.formattingContext = showAbbreviation ? .listItem : .standalone()
                currencyFormatter.currency = algoRawCurrency

                let text = currencyFormatter.format(amount)
                amountLabelText = .string(text)
            } catch {
                amountLabelText = nil
            }

            return
        }

        if showAbbreviation {
            currencyFormatter.formattingContext = .listItem
        } else {
            var constraintRules = CurrencyFormattingContextRules()
            constraintRules.maximumFractionDigits = assetFraction

            currencyFormatter.formattingContext = .standalone(constraints: constraintRules)
        }

        currencyFormatter.currency = nil

        let amountText = currencyFormatter.format(amount)
        let text = [ amountText, assetSymbol ].compound(" ")

        amountLabelText = .string(text)
    }
}
