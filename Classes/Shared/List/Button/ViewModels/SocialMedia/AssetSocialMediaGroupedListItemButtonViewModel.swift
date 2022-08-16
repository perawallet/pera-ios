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

//   AssetSocialMediaGroupedListItemButtonViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AssetSocialMediaGroupedListItemButtonViewModel: GroupedListItemButtonViewModel {
    private(set) var title: TextProvider?
    private(set) var listItemButtons: [ListItemButton] = []

    init(
        _ socialMedia: [AssetSocialMedia]
    ) {
        bindTitle()
        bindListItemButtons(socialMedia)
    }
}

extension AssetSocialMediaGroupedListItemButtonViewModel {
    private mutating func bindTitle() {
        title = "social-media-platform-title".footnoteMedium()
    }

    private mutating func bindListItemButtons(
        _ socialMedia: [AssetSocialMedia]
    ) {
        var buttons: [ListItemButton] = []

        for platform in socialMedia {
            let button = ListItemButton()
            let theme = ListItemButtonTheme()
            theme.configureForAssetSocialMediaView()
            button.customize(theme)

            switch platform {
            case .discord:
                let viewModel = AssetDiscordListItemButtonViewModel()
                button.bindData(viewModel)
            case .telegram:
                let viewModel = AssetTelegramListItemButtonViewModel()
                button.bindData(viewModel)
            case .twitter:
                let viewModel = AssetTwitterListItemButtonViewModel()
                button.bindData(viewModel)
            }

            buttons.append(button)
        }

        self.listItemButtons = buttons
    }
}

enum AssetSocialMedia {
    case discord
    case telegram
    case twitter
}
