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

//   AccountSelectNoContentViewModel.swift

import Foundation
import MacaroonUIKit

struct AccountSelectNoContentViewModel:
    NoContentViewModel,
    Hashable {
    private(set) var icon: Image?
    private(set) var title: TextProvider?
    private(set) var body: TextProvider?

    init(hasBody: Bool) {
        bindTitle()

        guard hasBody else {
            return
        }

        bindBody()
    }
}

extension AccountSelectNoContentViewModel {
    private mutating func bindTitle() {
        let font = Fonts.DMSans.medium.make(19)
        let lineHeightMultiplier = 1.13
        title =
            "account-select-search-empty-title"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .textAlignment(.center),
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
    }

    private mutating func bindBody() {
        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23
        body =
            "account-select-search-empty-detail"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .textAlignment(.center),
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
    }
}
