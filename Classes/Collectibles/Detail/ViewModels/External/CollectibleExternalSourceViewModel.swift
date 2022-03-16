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

//   CollectibleExternalSourceViewModel.swift

import Foundation
import MacaroonUIKit

struct CollectibleExternalSourceViewModel:
    ViewModel,
    Hashable {
    private(set) var icon: Image?
    private(set) var title: EditText?
    private(set) var action: Image?

    init(
        item: SingleLineIconTitleItem
    ) {
        bindIcon(item)
        bindTitle(item)
        bindAction()
    }
}

extension CollectibleExternalSourceViewModel {
    private mutating func bindIcon(
        _ item: SingleLineIconTitleItem
    ) {
        icon = item.icon
    }

    private mutating func bindTitle(
        _ item: SingleLineIconTitleItem
    ) {
        guard let aTitle = item.title else {
            return
        }

        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        title = .attributedString(
            aTitle.attributed([
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .lineBreakMode(.byWordWrapping),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ])
        )
    }

    private mutating func bindAction() {
        action = img("icon-external-link")
    }
}

extension CollectibleExternalSourceViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(title)
        hasher.combine(icon?.uiImage)
        hasher.combine(action?.uiImage)
    }

    static func == (
        lhs: CollectibleExternalSourceViewModel,
        rhs: CollectibleExternalSourceViewModel
    ) -> Bool {
        return lhs.title == rhs.title &&
            lhs.icon?.uiImage == rhs.icon?.uiImage &&
            lhs.action?.uiImage == rhs.action?.uiImage
    }
}
