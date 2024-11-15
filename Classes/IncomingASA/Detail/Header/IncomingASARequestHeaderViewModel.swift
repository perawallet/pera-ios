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

    init(
        draft: IncomingASAListItem,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        bindPrimaryValue(
            draft: draft,
            currencyFormatter: currencyFormatter
        )
        bindSecondaryValue(
            draft: draft,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }
}

extension IncomingASARequestHeaderViewModel {
    mutating func bindPrimaryValue(
        draft: IncomingASAListItem,
        currencyFormatter: CurrencyFormatter
    ) {
        bindAssetPrimaryValue(
            draft: draft,
            currencyFormatter: currencyFormatter
        )
    }

    mutating func bindAssetPrimaryValue(
        draft: IncomingASAListItem,
        currencyFormatter: CurrencyFormatter
    ) {
        currencyFormatter.formattingContext = .standalone()
        currencyFormatter.currency = nil

        let asset = draft.asset
        let amount = draft.totalAmount ?? 0
        let decimalAmount = amount.assetAmount(fromFraction: asset.decimals)
        let amountText = currencyFormatter.format(decimalAmount)
        let unitText =
            asset.naming.unitName.unwrapNonEmptyString() ?? asset.naming.name.unwrapNonEmptyString()
        let text = [amountText, unitText].compound(" ")
        bindPrimaryValue(text: text)
    }

    mutating func bindPrimaryValue(text: String?) {
        title = text?.titleSmallMedium(alignment: .center)
    }
    
    mutating func bindSecondaryValue(
        draft: IncomingASAListItem,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        bindAssetSecondaryValue(
            draft: draft,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }

    mutating func bindAssetSecondaryValue(
        draft: IncomingASAListItem,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let currencyValue = currency.primaryValue else {
            subTitle = nil
            return
        }

        let asset = draft.asset
        
        do {
            let rawCurrency = try currencyValue.unwrap()

            let amount = draft.totalAmount ?? 0
            let exchanger = CurrencyExchanger(currency: rawCurrency)
            let decimalAmount = amount.assetAmount(fromFraction: asset.decimals)
            let exchangedAmount = try exchanger.exchange(asset, amount: decimalAmount)

            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = rawCurrency

            let text = currencyFormatter.format(exchangedAmount)
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
