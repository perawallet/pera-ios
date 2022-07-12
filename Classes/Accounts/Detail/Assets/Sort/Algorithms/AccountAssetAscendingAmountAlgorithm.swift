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

//   AccountAssetAscendingAmountAlgorithm.swift

import Foundation

struct AccountAssetAscendingAmountAlgorithm: AccountAssetSortingAlgorithm {
    let id: String
    let name: String

    init() {
        self.id = "cache.value.accountAssetAscendingAmountAlgorithm"
        self.name = "title-lowest-value-to-highest".localized
    }
}

extension AccountAssetAscendingAmountAlgorithm {
    func getFormula(
        assetPreview: AssetPreviewModel,
        otherAssetPreview: AssetPreviewModel
    ) -> Bool {
        let assetPreviewCurrencyValue = assetPreview.currencyAmount
        let otherAssetPreviewCurrencyValue = otherAssetPreview.currencyAmount

        if assetPreviewCurrencyValue != otherAssetPreviewCurrencyValue {
            return assetPreviewCurrencyValue < otherAssetPreviewCurrencyValue
        }

        if let assetPreviewTitle = assetPreview.title,
           let otherAssetPreviewTitle = otherAssetPreview.title {
            return assetPreviewTitle < otherAssetPreviewTitle
        }

        if let assetPreviewID = assetPreview.asset?.id,
           let otherAssetPreviewID = otherAssetPreview.asset?.id {
            return assetPreviewID < otherAssetPreviewID
        }

        return false
    }
}
