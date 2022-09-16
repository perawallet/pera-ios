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

//   SignWithLedgerProcessScreenTheme.swift

import Foundation
import MacaroonUIKit

struct SignWithLedgerProcessScreenTheme:
    LayoutSheet,
    StyleSheet {
    let progressTopInset: LayoutMetric
    let progressTintColor: Color
    let trackTintColor: Color
    let contextEdgeInsets: LayoutPaddings
    let titleTopInset: LayoutMetric
    let title: TextStyle
    let spacingBetweenTitleAndBody: LayoutMetric
    let body: TextStyle
    let action: ButtonStyle
    let actionEdgeInsets: LayoutPaddings
    let actionContentEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        progressTopInset = 8
        progressTintColor = Colors.Helpers.positive
        trackTintColor = Colors.Layer.grayLighter
        contextEdgeInsets = (58, 24, 28, 24)
        titleTopInset = 24
        title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Typography.bodyLargeMedium())
        ]
        spacingBetweenTitleAndBody = 12
        body = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray),
            .font(Typography.bodyRegular())
        ]
        action = [
            .font(Typography.bodyMedium()),
            .titleColor([ .normal(Colors.Button.Secondary.text) ]),
            .backgroundImage([
                .normal("components/buttons/secondary/bg"),
                .highlighted("components/buttons/secondary/bg-highlighted"),
            ])
        ]
        actionEdgeInsets = (8, 24, 16, 24)
        actionContentEdgeInsets = (16, 24, 16, 24)
    }
}
