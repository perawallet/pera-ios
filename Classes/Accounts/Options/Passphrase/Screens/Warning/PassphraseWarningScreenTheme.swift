// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   PassphraseWarningScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct PassphraseWarningScreenTheme:
    StyleSheet,
    LayoutSheet {
    let background: ViewStyle
    let contextPaddings: LayoutPaddings
    let icon: ImageStyle
    let spacingBetweenIconAndTitle: LayoutMetric
    let title: TextStyle
    let spacingBetweenTitleAndDescription: LayoutMetric
    let description: TextStyle
    let spacingBetweendDescriptionAndMainButton: LayoutMetric
    let buttonHeight: LayoutMetric
    let mainButtonTheme: ButtonTheme
    let spacingBetweendMainAndSecondaryButtons: LayoutMetric
    let secondaryButtonTheme: ButtonTheme
    let secondaryButtonBottomPadding: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.contextPaddings = (32, 20, 20, 20)
        self.icon = [
            .image("icon-rekeyed")
        ]
        self.spacingBetweenIconAndTitle = 20
        
        self.title = [
            .text(String(localized: "title-passphrase-warning")),
            .textColor(Colors.Text.main),
            .textOverflow(SingleLineText()),
            .font(Typography.bodyLargeMedium()),
            .textAlignment(.center)
        ]
        self.spacingBetweenTitleAndDescription = 12
        
        self.description = [
            .text(String(localized: "passphrase-warning-description")),
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText()),
            .font(Typography.bodyRegular()),
            .textAlignment(.center)
        ]
        self.spacingBetweendDescriptionAndMainButton = 55
        
        self.buttonHeight = 52
        self.mainButtonTheme = ButtonPrimaryTheme()
        self.spacingBetweendMainAndSecondaryButtons = 12
        self.secondaryButtonTheme = ButtonSecondaryTheme()
        self.secondaryButtonBottomPadding = 10
    }
}
