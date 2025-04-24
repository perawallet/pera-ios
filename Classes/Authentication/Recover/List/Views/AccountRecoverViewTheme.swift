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
//   AccountRecoverViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

protocol AccountRecoverViewTheme: StyleSheet, LayoutSheet {
    var title: TextStyle { get }
    var horizontalStackViewTopInset: LayoutMetric { get }
    var horizontalStackViewSpacing: LayoutMetric { get }
    var horizontalInset: LayoutMetric { get }
    var topInset: LayoutMetric { get }
    var bottomInset: LayoutMetric { get }
    var verticalStackViewSpacing: LayoutMetric { get }
    var firstColumnCount: Int { get }
    var secondColumnCount: Int { get }
}

struct AccountRecoverViewAlgo25Theme: AccountRecoverViewTheme {
    let title: TextStyle
    let horizontalStackViewTopInset: LayoutMetric
    let horizontalStackViewSpacing: LayoutMetric
    let horizontalInset: LayoutMetric
    let topInset: LayoutMetric
    let bottomInset: LayoutMetric
    let verticalStackViewSpacing: LayoutMetric
    let firstColumnCount: Int
    let secondColumnCount: Int
    
    init(_ family: LayoutFamily) {
        self.title = [
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.medium.make(32)),
            .text(String(localized: "recover-from-seed-title"))
        ]

        self.horizontalStackViewTopInset = 37
        self.horizontalInset = 24
        self.topInset = 2
        self.bottomInset = 100
        self.horizontalStackViewSpacing = 8
        self.verticalStackViewSpacing = 12
        self.firstColumnCount = 13
        self.secondColumnCount = 12
    }
}

struct AccountRecoverViewBip39Theme: AccountRecoverViewTheme {
    let title: TextStyle
    let horizontalStackViewTopInset: LayoutMetric
    let horizontalStackViewSpacing: LayoutMetric
    let horizontalInset: LayoutMetric
    let topInset: LayoutMetric
    let bottomInset: LayoutMetric
    let verticalStackViewSpacing: LayoutMetric
    let firstColumnCount: Int
    let secondColumnCount: Int
    
    init(_ family: LayoutFamily) {
        self.title = [
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.medium.make(32)),
            .text(String(localized: "recover-from-seed-title"))
        ]

        self.horizontalStackViewTopInset = 37
        self.horizontalInset = 24
        self.topInset = 2
        self.bottomInset = 100
        self.horizontalStackViewSpacing = 8
        self.verticalStackViewSpacing = 12
        self.firstColumnCount = 12
        self.secondColumnCount = 12
    }
}
