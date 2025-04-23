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

//
//   PassphraseBackUpViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

protocol PassphraseBackUpViewTheme: StyleSheet, LayoutSheet {
    var backgroundColor: Color { get }
    var title: TextStyle { get }
    var description: TextStyle { get }
    var mainButtonTheme: ButtonTheme { get }
    var passphraseViewTheme: PassphraseViewTheme { get }
    var topInset: LayoutMetric { get }
    var containerTopInset: LayoutMetric { get }
    var collectionViewHeight: LayoutMetric { get }
    var bottomInset: LayoutMetric { get }
    var horizontalInset: LayoutMetric { get }
}

struct PassphraseBackUpViewCommonTheme: PassphraseBackUpViewTheme {
    let backgroundColor: Color
    let title: TextStyle
    let description: TextStyle

    let mainButtonTheme: ButtonTheme
    let passphraseViewTheme: PassphraseViewTheme

    let topInset: LayoutMetric
    let containerTopInset: LayoutMetric
    let collectionViewHeight: LayoutMetric
    let bottomInset: LayoutMetric
    let horizontalInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.title = [
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.medium.make(32)),
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .text("title-recover-passphrase".localized)
        ]
        self.description = [
            .textColor(Colors.Text.gray),
            .font(Typography.bodyRegular()),
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .text("passphrase-bottom-title-alg25".localized)
        ]

        self.mainButtonTheme = ButtonPrimaryTheme()
        self.passphraseViewTheme = PassphraseViewTheme()

        self.topInset = 2
        self.containerTopInset = 33
        self.collectionViewHeight = 456
        self.bottomInset = 16
        self.horizontalInset = 24
    }
}

struct PassphraseBackUpViewBip39Theme: PassphraseBackUpViewTheme {
    let backgroundColor: Color
    let title: TextStyle
    let description: TextStyle

    let mainButtonTheme: ButtonTheme
    let passphraseViewTheme: PassphraseViewTheme

    let topInset: LayoutMetric
    let containerTopInset: LayoutMetric
    let collectionViewHeight: LayoutMetric
    let bottomInset: LayoutMetric
    let horizontalInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.title = [
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.medium.make(32)),
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .text("recover-passphrase-title".localized)
        ]
        self.description = [
            .textColor(Colors.Text.gray),
            .font(Typography.bodyRegular()),
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .text("passphrase-bottom-title-bip39".localized)
            ]

        self.mainButtonTheme = ButtonPrimaryTheme()
        self.passphraseViewTheme = PassphraseViewTheme()

        self.topInset = 2
        self.containerTopInset = 33
        self.collectionViewHeight = 426
        self.bottomInset = 16
        self.horizontalInset = 24
    }
}
