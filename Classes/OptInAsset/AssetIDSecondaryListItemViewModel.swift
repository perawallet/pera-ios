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

//   AssetIDSecondaryListItemViewModel.swift

import Foundation
import MacaroonUIKit

struct AssetIDSecondaryListItemViewModel: SecondaryListItemViewModel {
    var title: TextProvider?
    var accessory: ButtonStyle?

    init(
        asset: AssetDecoration
    ) {
        bindTitle(asset)
        bindAccessory()
    }
}

extension AssetIDSecondaryListItemViewModel {
    private mutating func bindTitle(
        _ asset: AssetDecoration
    ) {
        title = getTitle(title: "\(asset.id)")
    }

    private mutating func bindAccessory() {
        let accessoryTitle: EditText =  .attributedString(
            "asset-copy-id"
                .localized
                .footnoteMedium(
                    lineBreakMode: .byTruncatingTail
                )
        )
        accessory = [
            .title(accessoryTitle),
            .titleColor([ .normal(AppColors.Components.Text.main) ] ),
            .backgroundColor(AppColors.Shared.Layer.grayLighter)
        ]
    }
}
