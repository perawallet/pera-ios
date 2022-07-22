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

//   AssetListItemViewModel.swift

import Foundation
import MacaroonUIKit

struct AssetListItemViewModel:
    PrimaryListItemViewModel,
    Hashable {
    var imageViewModel: PrimaryImageViewModel?
    var primaryTitleViewModel: PrimaryTitleViewModel?
    var secondaryTitleViewModel: PrimaryTitleViewModel?

    init(
        _ item: AssetItem
    ) {
        bindImageViewModel(item)
        bindPrimaryTitleViewModel(item)
        bindSecondaryTitleViewModel(item)
    }
}

extension AssetListItemViewModel {
    private mutating func bindImageViewModel(
        _ item: AssetItem
    ) {
        let title = item.asset.presentation.name.isNilOrEmpty
            ? "title-unknown".localized
            : item.asset.presentation.name

        imageViewModel = AssetImageLargeViewModel(
            image: .url(
                item.asset.presentation.logo,
                title: title
            )
        )
    }

    private mutating func bindPrimaryTitleViewModel(
        _ item: AssetItem
    ) {
        primaryTitleViewModel = AssetNameViewModel(item.asset)
    }

    private mutating func bindSecondaryTitleViewModel(
        _ item: AssetItem
    ) {
        secondaryTitleViewModel = AssetAmountViewModel(item)
    }
}
