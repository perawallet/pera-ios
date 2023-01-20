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
        viewModel: SortableAssetListItemViewModel,
        otherViewModel: SortableAssetListItemViewModel
    ) -> Bool {
        guard let assetPreviewCurrencyValue = viewModel.valueInUSD,
              let otherAssetPreviewCurrencyValue = otherViewModel.valueInUSD else {
            return false
        }

        if assetPreviewCurrencyValue != otherAssetPreviewCurrencyValue {
            return assetPreviewCurrencyValue < otherAssetPreviewCurrencyValue
        }

        if let assetTitle =
            viewModel.title?.primaryTitle?.string ??
            viewModel.title?.secondaryTitle?.string,
           let otherAssetTitle =
            otherViewModel.title?.primaryTitle?.string ??
            viewModel.title?.secondaryTitle?.string {
            let comparison = assetTitle.localizedCaseInsensitiveCompare(otherAssetTitle)
            return comparison == .orderedAscending
        }

        if let assetID = viewModel.asset?.id,
           let otherAssetID = otherViewModel.asset?.id {
            return assetID < otherAssetID
        }

        return false
    }
}
