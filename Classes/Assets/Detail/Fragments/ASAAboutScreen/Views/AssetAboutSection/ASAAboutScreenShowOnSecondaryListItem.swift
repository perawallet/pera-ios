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

//   ASAAboutScreenShowOnSecondaryListItem.swift

import Foundation
import MacaroonUIKit

struct ASAAboutScreenShowOnSecondaryListItemViewModel: SecondaryListItemViewModel {
    var title: TextProvider?
    var accessory: SecondaryListItemValueViewModel?

    init() {
        bindTitle()
        accessory = ASAAboutScreenShowOnListItemValueViewModel()
    }
}

extension ASAAboutScreenShowOnSecondaryListItemViewModel {
    private mutating func bindTitle() {
        var attributes = Typography.bodyRegularAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Text.gray))

        title =
            String(localized: "collectible-detail-show-on")
                .attributed(attributes)
    }
}

struct ASAAboutScreenShowOnListItemValueViewModel: SecondaryListItemValueViewModel {
    var icon: ImageStyle?
    var title: TextProvider?

    init() {
        bindIcon()
        bindTitle()
    }
}

extension ASAAboutScreenShowOnListItemValueViewModel {
    private mutating func bindTitle() {
        var attributes = Typography.bodyMediumAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Link.primary))

        title =
            String(localized: "collectible-detail-pera-explorer")
                .attributed(attributes)
    }

    private mutating func bindIcon() {
        icon = [
            .image("icon-pera-logo"),
            .contentMode(.left)
        ]
    }
}
