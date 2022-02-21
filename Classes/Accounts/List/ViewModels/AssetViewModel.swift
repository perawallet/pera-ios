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
//  AssetViewModel.swift

import UIKit
import MacaroonUIKit

struct AssetViewModel: ViewModel {
    private(set) var assetDetail: AssetDecoration?
    private(set) var amount: String?
    private(set) var currencyAmount: String?

    init(assetDetail: AssetDecoration?, asset: ALGAsset?, currency: Currency?) {
        bindAssetDetail(assetDetail)
        bindAmount(from: assetDetail, with: asset)
        bindCurrencyAmount(from: assetDetail, with: asset, and: currency)
    }
}

extension AssetViewModel {
    private mutating func bindAssetDetail(_ assetDetail: AssetDecoration?) {
        self.assetDetail = assetDetail
    }

    private mutating func bindAmount(from assetDetail: AssetDecoration?, with asset: ALGAsset?) {
        guard let assetDetail = assetDetail else {
            return
        }

        amount = asset?.amount
            .assetAmount(fromFraction: assetDetail.decimals)
            .toFractionStringForLabel(fraction: assetDetail.decimals)
    }

    private mutating func bindCurrencyAmount(from assetDetail: AssetDecoration?, with asset: ALGAsset?, and currency: Currency?) {
        guard let asset = asset,
              let assetDetail = assetDetail,
              let assetUSDValue = assetDetail.usdValue,
              let currency = currency,
              let currencyUSDValue = currency.usdValue else {
            return
        }

        let currencyValue = assetUSDValue * asset.amount.assetAmount(fromFraction: assetDetail.decimals) * currencyUSDValue
        if currencyValue > 0 {
            currencyAmount = currencyValue.toCurrencyStringForLabel(with: currency.symbol)
        }
    }
}
