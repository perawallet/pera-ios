// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   IncomingAsaRequestHeaderViewModel.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage

struct IncomingASARequestHeaderViewModel: ViewModel {
    private(set) var title: TextProvider?
    private(set) var subTitle: TextProvider?

    init(_ draft: IncomingASAListItem, currency: CurrencyProvider, currencyFormatter: CurrencyFormatter) {
        bindPrimaryValue(
            asset: draft.asset,
            currencyFormatter: currencyFormatter
        )
        bindSecondaryValue(
            asset: draft.asset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }
}

extension IncomingASARequestHeaderViewModel {
    
    mutating func bindPrimaryValue(
        asset: Asset,
        currencyFormatter: CurrencyFormatter
    ) {
        if asset.isAlgo {
            bindAlgoPrimaryValue(
                asset: asset,
                currencyFormatter: currencyFormatter
            )
        } else {
            bindAssetPrimaryValue(
                asset: asset,
                currencyFormatter: currencyFormatter
            )
        }
    }
    
    mutating func bindAlgoPrimaryValue(
        asset: Asset,
        currencyFormatter: CurrencyFormatter
    ) {
        currencyFormatter.formattingContext = .standalone()
        currencyFormatter.currency = AlgoLocalCurrency()

        let text = currencyFormatter.format(asset.decimalAmount)
        bindPrimaryValue(text: text)
    }

    mutating func bindAssetPrimaryValue(
        asset: Asset,
        currencyFormatter: CurrencyFormatter
    ) {
        currencyFormatter.formattingContext = .standalone()
        currencyFormatter.currency = nil

        let amountText = currencyFormatter.format(asset.decimalAmount)
        let unitText =
            asset.naming.unitName.unwrapNonEmptyString() ?? asset.naming.name.unwrapNonEmptyString()
        let text = [ amountText, unitText ].compound(" ")
        bindPrimaryValue(text: text)
    }

    mutating func bindPrimaryValue(text: String?) {
        title = text?.titleSmallMedium(alignment: .center)
    }
    
    
    mutating func bindSecondaryValue(
        asset: Asset,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        if asset.isAlgo {
            bindAlgoSecondaryValue(
                asset: asset,
                currency: currency,
                currencyFormatter: currencyFormatter
            )
        } else {
            bindAssetSecondaryValue(
                asset: asset,
                currency: currency,
                currencyFormatter: currencyFormatter
            )
        }
    }

    mutating func bindAlgoSecondaryValue(
        asset: Asset,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let fiatCurrencyValue = currency.fiatValue else {
            subTitle = nil
            return
        }

        do {
            let fiatRawCurrency = try fiatCurrencyValue.unwrap()

            let exchanger = CurrencyExchanger(currency: fiatRawCurrency)
            let amount = try exchanger.exchangeAlgo(amount: asset.decimalAmount)

            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = fiatRawCurrency

            let text = currencyFormatter.format(amount)
            bindSecondaryValue(text: text)
        } catch {
            subTitle = nil
        }
    }

    mutating func bindAssetSecondaryValue(
        asset: Asset,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let currencyValue = currency.primaryValue else {
            subTitle = nil
            return
        }

        do {
            let rawCurrency = try currencyValue.unwrap()

            let exchanger = CurrencyExchanger(currency: rawCurrency)
            let amount = try exchanger.exchange(asset)

            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = rawCurrency

            let text = currencyFormatter.format(amount)
            bindSecondaryValue(text: text)
        } catch {
            subTitle = nil
        }
    }

    mutating func bindSecondaryValue(text: String?) {
        if let text = text.unwrapNonEmptyString() {
            subTitle = text.bodyMedium(alignment: .center)
        } else {
            subTitle = nil
        }
    }
}
