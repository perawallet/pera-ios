// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   IncomingAsasDetailScreen+Theme.swift

import Foundation
import MacaroonUIKit
import UIKit

extension IncomingASAsDetailScreen {
    struct Theme: LayoutSheet, StyleSheet {
        let backgroundColor: Color
        let spacingBetweenListAndPrimaryAction: LayoutMetric
        let primaryAction: ButtonStyle
        let secondaryAction: ButtonStyle
        let secondaryActionWidthMultiplier: LayoutMetric
        let actionEdgeInsets: LayoutPaddings
        let actionMargins: LayoutMargins
        let spacingBetweenActions: LayoutMetric
        
        init(_ family: LayoutFamily) {
            self.backgroundColor = Colors.Defaults.background
            self.spacingBetweenListAndPrimaryAction = 24
            self.primaryAction = [
                .title("incoming-asa-detail-screen-right-button-title".localized),
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
            self.secondaryAction = [
                .title("incoming-asa-detail-screen-left-button-title".localized),
                .font(Typography.bodyMedium()),
                .titleColor([
                    .normal(Colors.Button.Secondary.text)
                ]),
                .backgroundImage([
                    .normal("components/buttons/secondary/bg"),
                    .highlighted("components/buttons/secondary/bg-highlighted")
                ])
            ]
            self.secondaryActionWidthMultiplier = 1.5
            self.actionEdgeInsets = (16, 8, 16, 8)
            self.actionMargins = (.noMetric, 24, 12, 24)
            self.spacingBetweenActions = 20
        }
    }
}
