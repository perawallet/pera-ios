// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   LedgerAccountVerificationViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct LedgerAccountVerificationViewTheme: StyleSheet, LayoutSheet {
    let image: ImageStyle
    let title: TextStyle
    let description: TextStyle
    let backgroundColor: Color
    
    let accountVerificationsStackViewVerticalPadding: LayoutMetric
    let verticalStackViewTopPadding: LayoutMetric
    let verticalStackViewSpacing: LayoutMetric
    let titleLabelTopPadding: LayoutMetric
    let accountVerificationListTopPadding: LayoutMetric
    let horizontalInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.title = [
            .textAlignment(.center),
            .textOverflow(FittingText()),
            .font(Fonts.DMSans.medium.make(19)),
            .textColor(Colors.Text.main),
            .text(String(localized: "ledger-verify-header-title"))
        ]
        self.description = [
            .textAlignment(.center),
            .textOverflow(FittingText()),
            .font(Fonts.DMSans.regular.make(15)),
            .textColor(Colors.Text.gray),
            .text(String(localized: "ledger-verify-header-subtitle"))
        ]
        self.image = [
            .image("icon-ledger"),
            .contentMode(.scaleAspectFit)
        ]

        self.accountVerificationsStackViewVerticalPadding = 12
        self.verticalStackViewTopPadding = 66
        self.verticalStackViewSpacing = 16
        self.titleLabelTopPadding = 30
        self.accountVerificationListTopPadding = 60
        self.horizontalInset = 24
    }
}
