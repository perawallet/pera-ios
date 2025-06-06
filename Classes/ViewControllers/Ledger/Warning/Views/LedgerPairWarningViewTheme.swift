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
//   LedgerPairWarningViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct LedgerPairWarningViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let image: ImageStyle
    let title: TextStyle
    let subtitle: TextStyle
    let actionButton: ButtonStyle
    let actionButtonContentEdgeInsets: LayoutPaddings
    let actionButtonCorner: Corner
    let instuctionViewTheme: InstructionItemViewTheme

    let bottomInset: LayoutMetric
    let horizontalInset: LayoutMetric
    let topInset: LayoutMetric
    let descriptionTopInset: LayoutMetric
    let titleTopInset: LayoutMetric
    let buttonTopInset: LayoutMetric
    let instructionVerticalStackViewTopPadding: LayoutMetric
    let instructionSpacing: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.image = [
            .image("icon-info-red")
        ]
        self.title = [
            .text(Self.getTitle()),
            .textColor(Colors.Text.main),
            .textOverflow(FittingText()),
        ]
        self.subtitle = [
            .text(Self.getSubtitle()),
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText()),
        ]
        self.actionButton = [
            .title(String(localized: "title-close")),
            .titleColor([ .normal(Colors.Button.Secondary.text) ]),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundColor(Colors.Button.Secondary.background)
        ]
        self.instuctionViewTheme = InstructionItemViewTheme(family)
        self.actionButtonContentEdgeInsets = (14, 0, 14, 0)
        self.actionButtonCorner = Corner(radius: 4)

        self.buttonTopInset = 32
        self.horizontalInset = 24
        self.topInset = 32
        self.titleTopInset = 20
        self.descriptionTopInset = 12
        self.bottomInset = 16
        self.instructionVerticalStackViewTopPadding = 40
        self.instructionSpacing = 28
    }
}

extension LedgerPairWarningViewTheme {
    private static func getTitle() -> EditText {
        return .attributedString(
            String(localized: "ledger-pairing-first-warning-title")
                .bodyLargeMedium(
                    alignment: .center
                )
        )
    }

    private static func getSubtitle()  -> EditText {
        return .attributedString(
            String(localized: "ledger-pairing-first-warning-description")
                .bodyRegular(
                    alignment: .center
                )
        )
    }
}
