// Copyright 2022-2025 Pera Wallet, LDA

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
    var accessory: SecondaryListItemValueViewModel?

    init(assetID: AssetID) {
        bindTitle(assetID)

        accessory = AssetIDSecondaryListItemValueViewModel()
    }
}

extension AssetIDSecondaryListItemViewModel {
    private mutating func bindTitle(_ assetID: AssetID) {
        var attributes = Typography.bodyRegularAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Text.gray))

        title = "\(assetID)".attributed(attributes)
    }
}

struct AssetIDSecondaryListItemValueViewModel: SecondaryListItemValueViewModel {
    var icon: ImageStyle?
    var title: TextProvider?

    init() {
        bindTitle()
    }
}

extension AssetIDSecondaryListItemValueViewModel {
    private mutating func bindTitle() {
        var attributes = Typography.footnoteMediumAttributes(
            lineBreakMode: .byTruncatingTail
        )
        attributes.insert(.textColor(Colors.Text.main))

        title =
            String(localized: "title-copy-id")
                .attributed(
                    attributes
                )
    }
}
