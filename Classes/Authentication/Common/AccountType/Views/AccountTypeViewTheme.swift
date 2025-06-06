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
//   AccountTypeViewTheme.swift

import MacaroonUIKit
import Foundation
import UIKit

struct AccountTypeViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let title: TextStyle
    let detail: TextStyle
    let warning: TextStyle
    let warningIcon: ImageStyle

    let badge: TextStyle
    let badgeCorner: Corner
    let badgeContentEdgeInsets: LayoutPaddings
    let badgeHorizontalEdgeInsets: NSDirectionalHorizontalEdgeInsets

    let iconSize: LayoutSize
    let warningIconSize: LayoutSize
    let horizontalInset: LayoutMetric
    let verticalInset: LayoutMetric
    let minimumInset: LayoutMetric
    let warningIconAndTextSpacing: LayoutMetric
    let dashedLineInset: LayoutMetric
    let warningViewHeight: LayoutMetric
    let warningViewHorizontalInset: LayoutMetric
    let warningViewTopInset: LayoutMetric
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.title = [
            .textOverflow(FittingText()),
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(Colors.Text.main),
            .textAlignment(.left),
            .isInteractable(false)
        ]
        self.detail = [
            .textOverflow(FittingText()),
            .font(Fonts.DMSans.regular.make(13)),
            .textColor(Colors.Text.gray),
            .textAlignment(.left),
            .isInteractable(false)
        ]
        self.warning = [
            .textOverflow(FittingText()),
            .font(Typography.footnoteMedium()),
            .textColor(Colors.Wallet.wallet3),
            .text(String(localized: "account-type-selection-universal-wallet-warning-title")),
            .backgroundColor(Colors.Defaults.background),
            .textAlignment(.center),
            .isInteractable(false)
        ]
        self.warningIcon = [
            .image("icon-info-20".templateImage),
            .tintColor(Colors.Wallet.wallet3)
        ]
        self.badge = [
            .textColor(Colors.Helpers.positive),
            .font(Typography.captionBold()),
            .textAlignment(.center),
            .textOverflow(SingleLineText()),
            .backgroundColor(Colors.Helpers.positiveLighter)
        ]
        self.badgeCorner = Corner(radius: 8)
        self.badgeContentEdgeInsets =  (3, 6, 3, 6)
        self.badgeHorizontalEdgeInsets = .init(
            leading: 8,
            trailing: 24
        )

        self.iconSize = (40, 40)
        self.warningIconSize = (20, 20)
        self.horizontalInset = 24
        self.verticalInset = 24
        self.minimumInset = 2
        self.warningIconAndTextSpacing = 3
        self.dashedLineInset = 12
        self.warningViewHeight = 20
        self.warningViewHorizontalInset = 12
        self.warningViewTopInset = 2
    }
}
