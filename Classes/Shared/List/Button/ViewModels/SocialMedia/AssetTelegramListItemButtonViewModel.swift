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

//   AssetTelegramListItemButtonViewModel.swift

import MacaroonUIKit

struct AssetTelegramListItemViewModel: GroupedListItemButtonItemViewModel {
    var theme: ListItemButtonTheme
    var viewModel: ListItemButtonViewModel
    var selector: () -> Void

    init(selector: @escaping () -> Void) {
        self.theme = Self.makeTheme()
        self.viewModel = AssetTelegramListItemButtonViewModel()
        self.selector = selector
    }
}

private struct AssetTelegramListItemButtonViewModel: ListItemButtonViewModel {
    var icon: Image?
    var title: EditText?
    var subtitle: EditText?
    var accessory: Image?

    init() {
        self.icon = "icon-telegram"
        self.title = .attributedString(
            "social-media-platform-telegram"
                .localized
                .bodyRegular(lineBreakMode: .byTruncatingTail)
        )
        self.subtitle = nil
        self.accessory = "icon-external-link"
    }
}
