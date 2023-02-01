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

//   AccountAssetDescendingAmountAlgorithm.swift

import Foundation

struct AccountAssetDescendingAmountAlgorithm: AccountAssetSortingAlgorithm {
    let id: String
    let name: String

    init() {
        self.id = "cache.value.accountAssetDescendingAmountAlgorithm"
        self.name = "title-highest-value-to-lowest".localized
    }
}

extension AccountAssetDescendingAmountAlgorithm {
    func getFormula(
        viewModel: SortableAssetListItemViewModel,
        otherViewModel: SortableAssetListItemViewModel
    ) -> Bool {
        guard let assetPreviewCurrencyValue = viewModel.valueInUSD,
              let otherAssetPreviewCurrencyValue = otherViewModel.valueInUSD else {
            return false
        }

        if assetPreviewCurrencyValue != otherAssetPreviewCurrencyValue {
            return assetPreviewCurrencyValue > otherAssetPreviewCurrencyValue
        }

        let titleSortingAlgorithm = AccountAssetAscendingTitleAlgorithm()
        
        return titleSortingAlgorithm.getFormula(viewModel: viewModel, otherViewModel: otherViewModel)
    }
}
