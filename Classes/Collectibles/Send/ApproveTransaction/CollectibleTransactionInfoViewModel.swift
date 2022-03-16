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

//   CollectibleTransactionInfoViewModel.swift

import MacaroonUIKit
import UIKit

struct CollectibleTransactionInfoViewModel: ViewModel {
    private(set) var title: EditText?
    private(set) var icon: UIImage?
    private(set) var value: EditText?

    init() {
        title = getTitle("Sender Account")
        icon = AccountType.standard.image(
            for: AccountImageType.getRandomImage(for: .standard)
        )
        value = getValue("QKZ6V2..2IHJA")
        /// <todo>: Remove mock data when screen is connected to the flow.
        fatalError()
    }
}

extension CollectibleTransactionInfoViewModel {
    private func getTitle(
        _ aTitle: String
    ) -> EditText {
        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        return .attributedString(
            aTitle
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byTruncatingTail),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
        )
    }

    private func getValue(
        _ aValue: String
    ) -> EditText {
        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        return .attributedString(
            aValue
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byTruncatingTail),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
        )
    }
}
