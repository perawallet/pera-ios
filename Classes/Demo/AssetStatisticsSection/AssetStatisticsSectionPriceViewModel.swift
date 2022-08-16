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

//   AssetStatisticsSectionPriceViewModel.swift

import MacaroonUIKit

struct AssetStatisticsSectionPriceViewModel: PrimaryTitleViewModel {
    var title: EditText?
    var icon: Image?
    var subtitle: EditText?

    init() {
        bindTitle()
        bindSubtitle()
    }
}

extension AssetStatisticsSectionPriceViewModel {
    private mutating func bindTitle() {
        title = .attributedString(
            "title-price"
                .localized
                .footnoteRegular(
                    lineBreakMode: .byTruncatingTail
                )
        )
    }

    private mutating func bindSubtitle() {
        subtitle = .attributedString(
            "$0.4101"
                .bodyLargeMedium(
                    lineBreakMode: .byTruncatingTail
                )
        )
    }
}
