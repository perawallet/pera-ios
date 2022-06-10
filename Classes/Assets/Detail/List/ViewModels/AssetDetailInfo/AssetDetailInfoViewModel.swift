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
//   AssetDetailInfoViewModel.swift

import Foundation
import MacaroonUIKit

struct AssetDetailInfoViewModel:
    ViewModel,
    Hashable {
    private(set) var yourBalanceTitle: EditText?
    private(set) var isVerified: Bool = false
    private(set) var amount: EditText?
    private(set) var secondaryValue: EditText?
    private(set) var name: EditText?
    private(set) var ID: EditText?

    init(
        _ account: Account,
        _ assetDetail: StandardAsset,
        _ currency: Currency?
    ) {
        bind(
            account,
            assetDetail,
            currency
        )
    }
}

extension AssetDetailInfoViewModel {
    private mutating func bind(
        _ account: Account,
        _ assetDetail: StandardAsset,
        _ currency: Currency?
    ) {
        bindYourBalanceTitle()
        bindIsVerified(from: assetDetail)
        bindName(from: assetDetail)
        bindAmount(from: assetDetail, in: account)
        bindSecondaryValue(from: assetDetail, with: account, and: currency)
        bindID(from: assetDetail)
    }

    private mutating func bindYourBalanceTitle() {
        yourBalanceTitle = .attributedString(
            "accounts-transaction-your-balance"
                .localized
                .bodyRegular()
        )
    }

    private mutating func bindIsVerified(
        from assetDetail: StandardAsset
    ) {
        isVerified = assetDetail.isVerified
    }

    private mutating func bindName(
        from assetDetail: StandardAsset
    ) {
        name = .attributedString(
            assetDetail.presentation.displayNames.primaryName
                .bodyMedium()
        )
    }

    private mutating func bindAmount(
        from assetDetail: StandardAsset,
        in account: Account
    ) {
        guard let fractionStringForLabel = assetDetail.amountWithFraction.toFractionStringForLabel(fraction: assetDetail.decimals) else {
            return
        }

        amount = .attributedString(
            fractionStringForLabel
                .largeTitleMonoRegular()
        )
    }

    private mutating func bindSecondaryValue(
        from assetDetail: StandardAsset,
        with account: Account,
        and currency: Currency?
    ) {
        guard let assetUSDValue = assetDetail.usdValue,
              let currency = currency,
              let currencyUSDValue = currency.usdValue else {
            return
        }

        let currencyValue = assetUSDValue * assetDetail.amountWithFraction * currencyUSDValue
        if currencyValue > 0,
           let currenyStringForLabel =
            currencyValue.toCurrencyStringForLabel(with: currency.symbol) {

            secondaryValue = .attributedString(
                currenyStringForLabel
                    .bodyMonoRegular()
            )
        }
    }

    private mutating func bindID(
        from assetDetail: StandardAsset
    ) {
        ID = .attributedString(
            "asset-detail-id-title".localized(params: "\(assetDetail.id)")
                .bodyRegular()
        )
    }
}
