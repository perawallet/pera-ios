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

//   BalancePercentageInputtViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct BalancePercentageInputViewModel: AdjustableSingleSelectionInputViewModel {
    private(set) var selectableInputs: [Segment] = [
        BalancePercentageInput(.init(value: 0.25)),
        BalancePercentageInput(.init(value: 0.5)),
        BalancePercentageInput(.init(value: 0.75)),
        BalancePercentageInput(
            .init(value: 1, customTitle: "swap-amount-balancePercentage-max".localized)
        )
    ]
}

struct BalancePercentageInput: Segment {
    let layout: Segment.Layout
    let style: Segment.Style
    let contentEdgeInsets: UIEdgeInsets

    init(_ percentage: BalancePercentage) {
        self.layout = .none
        self.style = [
            .backgroundImage([
                .normal("swap-selector-background-normal"),
                .selected("swap-selector-background-selected")
            ]),
            .font(Typography.footnoteMedium()),
            .title(percentage.title),
            .titleColor([
                .normal(Colors.Button.Secondary.text),
                .selected(Colors.Helpers.positive)
            ]),
        ]
        self.contentEdgeInsets = .init(top: 8, left: 12, bottom: 8, right: 12)
    }
}

struct BalancePercentage: Equatable {
    let value: Float
    let title: String

    init(value: Float) {
        self.value = value
        self.title = Double(value).toPercentageWith(fractions: 2) ?? String(value)
    }

    init(
        value: Float,
        customTitle: String
    ) {
        self.value = value
        self.title = customTitle
    }
}
