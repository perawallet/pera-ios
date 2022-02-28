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
    private(set) var assetDetail: StandardAsset?
    private(set) var amount: String?
    private(set) var currencyAmount: String?

    init(
        asset: StandardAsset?,
        currency: Currency?
    ) {
        bindAssetDetail(asset)
        bindAmount(from: asset)
        bindCurrencyAmount(from: asset, with: currency)
    }
}

extension AssetViewModel {
    private mutating func bindAssetDetail(
        _ asset: StandardAsset?
    ) {
        self.assetDetail = asset
    }

    private mutating func bindAmount(
        from asset: StandardAsset?
    ) {
        guard let asset = asset else {
            return
        }

        amount = asset.amount
            .assetAmount(fromFraction: asset.decimals)
            .toFractionStringForLabel(fraction: asset.decimals)
    }

    private mutating func bindCurrencyAmount(
        from asset: StandardAsset?,
        with currency: Currency?
    ) {
        guard let asset = asset,
              let assetUSDValue = asset.usdValue,
              let currency = currency,
              let currencyUSDValue = currency.usdValue else {
            return
        }

        let currencyValue = assetUSDValue * asset.amount.assetAmount(fromFraction: asset.decimals) * currencyUSDValue
        if currencyValue > 0 {
            currencyAmount = currencyValue.toCurrencyStringForLabel(with: currency.symbol)
        }
    }
}
