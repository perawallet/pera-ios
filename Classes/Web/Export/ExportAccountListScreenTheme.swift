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

//   ExportAccountListScreenTheme.swift


import Foundation
import MacaroonUIKit

struct ExportAccountListScreenTheme:
    LayoutSheet,
    StyleSheet {
    let background: ViewStyle
    let continueAllAction: ButtonStyle
    let continueAllActionEdgeInsets: LayoutPaddings
    let continueAllActionMargins: LayoutMargins
    let spacingBetweenListAndContinueAction: LayoutMetric

    init(_ family: LayoutFamily) {
        background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        continueAllAction = [
            .title("title-continue".localized),
            .font(Typography.bodyMedium()),
            .titleColor([
                .normal(Colors.Button.Primary.text),
                .disabled(Colors.Button.Primary.disabledText)
            ]),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
                .disabled("components/buttons/primary/bg-disabled")
            ])
        ]
        continueAllActionEdgeInsets = (16, 8, 16, 8)
        continueAllActionMargins = (.noMetric, 24, 12, 24)
        spacingBetweenListAndContinueAction = 16
    }
}
