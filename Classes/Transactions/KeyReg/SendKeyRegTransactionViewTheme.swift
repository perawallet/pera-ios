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

//   SendKeyRegTransactionViewTheme.swift

import MacaroonUIKit
import SwiftUI

struct SendKeyRegTransactionViewTheme: LayoutSheet, StyleSheet {
    let background: SwiftUI.Color
    let itemSpacing: LayoutMetric
    let topSpacing: LayoutMetric
    let horizontalSpacing: LayoutMetric
    let dividerSpacing: LayoutMetric
    let lineItemHorizontalSpacing: LayoutMetric
    let titleColor: SwiftUI.Color
    let titleFont: SwiftUI.Font
    let titleMaxWidth: LayoutMetric
    let noteButtonSpacing: LayoutMetric
    let valueColor: SwiftUI.Color
    let valueFont: SwiftUI.Font
    let noteButtonFont: SwiftUI.Font
    let noteButtonForegroundColor: SwiftUI.Color
    let rawTxnButtonFont: SwiftUI.Font
    let rawTxnButtonForegroundColor: SwiftUI.Color
    let rawTxnButtonBackgroundColor: SwiftUI.Color
    let rawTxnButtonVerticalSpacing: LayoutMetric
    let rawTxnButtonHorizontalSpacing: LayoutMetric
    let rawTxnButtonCornerRadius: LayoutMetric
    let rawTxnButtonBottomPadding: LayoutMetric
    let buttonRadius: LayoutMetric
    let buttonHeight: LayoutMetric
    let buttonBackground: SwiftUI.Color
    let buttonForeground: SwiftUI.Color
    let buttonFont: SwiftUI.Font

    init(_ family: LayoutFamily) {
        self.background = Color(Colors.Defaults.background.rawValue)
        self.itemSpacing = 20
        self.topSpacing = 40
        self.horizontalSpacing = 24
        self.dividerSpacing = 8
        self.lineItemHorizontalSpacing = 20
        self.titleColor = Color(Colors.Text.gray.rawValue)
        self.titleFont = Typography.bodyRegular().font
        self.titleMaxWidth = 112
        self.noteButtonSpacing = 2
        self.valueColor = Color(Colors.Text.main.rawValue)
        self.valueFont = Typography.bodyRegular().font
        self.noteButtonFont = Typography.bodyMedium().font
        self.noteButtonForegroundColor = Color(Colors.Helpers.positive.rawValue)
        self.rawTxnButtonFont = Typography.footnoteMedium().font
        self.rawTxnButtonForegroundColor = Color(Colors.Button.Secondary.text.rawValue)
        self.rawTxnButtonBackgroundColor = Color(Colors.Button.Secondary.background.rawValue)
        self.rawTxnButtonVerticalSpacing = 8
        self.rawTxnButtonHorizontalSpacing = 12
        self.rawTxnButtonCornerRadius = 18
        self.rawTxnButtonBottomPadding = 24
        self.buttonRadius = 4
        self.buttonHeight = 52
        self.buttonBackground = Color(Colors.Button.Primary.background.rawValue)
        self.buttonForeground = Color(Colors.Button.Primary.text.rawValue)
        self.buttonFont = Typography.bodyMedium().font
    }
}
