// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AlgorandSecureBackupInstructionItemViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AlgorandSecureBackupInstructionItemViewTheme:
    StyleSheet,
    LayoutSheet {
    var number: TextStyle
    var numberFirstShadow: MacaroonUIKit.Shadow
    var numberSecondShadow: MacaroonUIKit.Shadow
    var numberThirdShadow: MacaroonUIKit.Shadow
    var numberSize: LayoutSize
    var spacingBetweenNumberAndContent: LayoutMetric
    var title: TextStyle
    var spacingBetweenTitleAndSubtitle: LayoutMetric
    var subtitle: TextStyle

    init(
        _ family: LayoutFamily
    ) {
        self.number = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText()),
        ]
        self.numberFirstShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow3.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            spread: 1,
            cornerRadii: (20, 20),
            corners: .allCorners
        )
        self.numberSecondShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow2.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: 0,
            cornerRadii: (20, 20),
            corners: .allCorners
        )
        self.numberThirdShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow1.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: -1,
            cornerRadii: (20, 20),
            corners: .allCorners
        )
        self.numberSize = (40, 40)
        self.spacingBetweenNumberAndContent = 20
        self.title = [
            .textColor(Colors.Text.main),
            .textOverflow(FittingText()),
        ]
        self.spacingBetweenTitleAndSubtitle = 8
        self.subtitle = [
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText()),
        ]
    }
}
