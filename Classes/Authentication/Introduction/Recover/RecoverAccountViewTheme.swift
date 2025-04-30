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

//   RecoverAccountViewTheme.swift

import MacaroonUIKit
import Foundation
import UIKit

protocol RecoverAccountViewTheme: StyleSheet, LayoutSheet {
    var backgroundColor: Color { get }
    var title: TextStyle { get }
    var accountTypeViewTheme: AccountTypeViewTheme { get }
    var horizontalInset: LayoutMetric { get }
    var topInset: LayoutMetric { get }
    var verticalInset: LayoutMetric { get }
}

struct RecoverAddAccountViewTheme: RecoverAccountViewTheme {
    let backgroundColor: Color
    let title: TextStyle
    let accountTypeViewTheme: AccountTypeViewTheme

    let horizontalInset: LayoutMetric
    let topInset: LayoutMetric
    let verticalInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.title = [
            .text(String(localized: "account-type-selection-import-wallet")),
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.medium.make(32))
        ]
        self.accountTypeViewTheme = AccountTypeViewTheme()

        self.horizontalInset = 24
        self.verticalInset = 20
        self.topInset = 2
    }
}

struct RecoverWelcomeAccountViewTheme: RecoverAccountViewTheme {
    let backgroundColor: Color
    let title: TextStyle
    let accountTypeViewTheme: AccountTypeViewTheme

    let horizontalInset: LayoutMetric
    let topInset: LayoutMetric
    let verticalInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.title = [
            .text(String(localized: "account-type-selection-recover")),
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.medium.make(32))
        ]
        self.accountTypeViewTheme = AccountTypeViewTheme()

        self.horizontalInset = 24
        self.verticalInset = 20
        self.topInset = 2
    }
}
