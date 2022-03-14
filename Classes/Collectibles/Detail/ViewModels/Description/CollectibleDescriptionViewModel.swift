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

//   CollectibleDescriptionViewModel.swift

import Foundation
import MacaroonUIKit

struct CollectibleDescriptionViewModel: ViewModel {
    private(set) var description: EditText?

    init(
        _ description: String?
    ) {
        bindDescription(description)
    }
}

extension CollectibleDescriptionViewModel {
    private mutating func bindDescription(
        _ aDescription: String?
    ) {
        guard let aDescription = aDescription else {
            return
        }

        let font = Fonts.DMSans.medium.make(15)
        let lineHeightMultiplier = 1.23

        description = .attributedString(
            aDescription.attributed([
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .lineBreakMode(.byWordWrapping),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ])
        )
    }
}
