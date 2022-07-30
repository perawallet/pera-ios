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

//   AlgoListItemViewModel.swift

import Foundation
import MacaroonUIKit

struct AlgoListItemViewModel:
    ALGAssetListItemViewModel,
    Hashable {
    var imageViewModel: PrimaryImageViewModel?
    var primaryTitleViewModel: PrimaryTitleViewModel?
    var secondaryTitleViewModel: PrimaryTitleViewModel?

    let asset: Asset? = nil

    init(
        _ item: AlgoAssetItem
    ) {
        bindImageViewModel()
        bindPrimaryTitleViewModel()
        bindSecondaryTitleViewModel(item)
    }
}

extension AlgoListItemViewModel {
    private mutating func bindImageViewModel() {
        imageViewModel = StandardAssetImageViewModel(image: .algo)
    }

    private mutating func bindPrimaryTitleViewModel() {
        primaryTitleViewModel = AssetNameViewModel(nil)
    }

    private mutating func bindSecondaryTitleViewModel(
        _ item: AlgoAssetItem
    ) {
        secondaryTitleViewModel = AlgoAmountViewModel(item)
    }
}
