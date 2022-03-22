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
    private(set) var valueStyle: TextStyle?

    init(
        _ information: CollectibleTransactionInformation
    ) {
        bindTitle(information)
        bindIcon(information)
        bindValue(information)
        bindValueStyle(information)
    }
}

extension CollectibleTransactionInfoViewModel {
    private mutating func bindTitle(
        _ information: CollectibleTransactionInformation
    ) {
        title = getTitle(information.title)
    }

    private mutating func bindIcon(
        _ information: CollectibleTransactionInformation
    ) {
        guard let account = information.account else {
            return
        }

        icon = account.image
    }

    private mutating func bindValue(
        _ information: CollectibleTransactionInformation
    ) {
        value = getValue(information.value)
    }

    private mutating func bindValueStyle(
        _ information: CollectibleTransactionInformation
    ) {
        if information.isForegroundingValue {
            valueStyle = [
                .textOverflow(FittingText()),
                .textAlignment(.right),
                .font(Fonts.DMSans.medium.make(15)),
                .textColor(AppColors.Components.Link.primary)
            ]
            return
        }

        valueStyle = [
            .textOverflow(FittingText()),
            .textAlignment(.right),
            .font(Fonts.DMSans.regular.make(15)),
            .textColor(AppColors.Components.Text.main)
        ]
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
                        .textAlignment(.left),
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
                        .textAlignment(.right),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
        )
    }
}

struct CollectibleTransactionInformation: Hashable {
    let account: Account?
    let title: String
    let value: String
    let isForegroundingValue: Bool
}
