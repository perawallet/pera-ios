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

//   AccountAssetAscendingTitleAlgorithm.swift

import Foundation
import MacaroonUtils

struct AccountAssetAscendingTitleAlgorithm: AccountAssetSortingAlgorithm {
    let id: String
    let name: String

    init() {
        self.id = "cache.value.accountAssetAscendingTitleAlgorithm"
        self.name = "title-alphabetically-a-to-z".localized
    }
}

extension AccountAssetAscendingTitleAlgorithm {
    func getFormula(
        asset: Asset,
        otherAsset: Asset
    ) -> Bool {
        let assetTitle = getSortableTitle(from: asset)
        let otherAssetTitle = getSortableTitle(from: otherAsset)
        
        guard let anAssetTitle = assetTitle.unwrapNonEmptyString() else {
            return false
        }

        guard let anotherAssetTitle = otherAssetTitle.unwrapNonEmptyString() else {
            return true
        }

        let result = anAssetTitle.localizedCaseInsensitiveCompare(anotherAssetTitle)
        return result == .orderedAscending
    }
    
    func getSortableTitle(from asset: Asset) -> String? {
        return asset.naming.name ??
            asset.naming.unitName ??
            String(asset.id)
    }
}
