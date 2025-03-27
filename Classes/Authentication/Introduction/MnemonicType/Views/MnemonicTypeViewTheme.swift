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

//   MnemonicTypeViewTheme.swift

import MacaroonUIKit
import Foundation
import UIKit

protocol MnemonicTypeViewTheme: StyleSheet, LayoutSheet {
    var backgroundColor: Color { get }
    var firstShadow: MacaroonUIKit.Shadow { get }
    var secondShadow: MacaroonUIKit.Shadow { get }
    var thirdShadow: MacaroonUIKit.Shadow { get }
    var title: TextStyle { get }
    var detail: TextStyle { get }
    var info: TextStyle { get }
    var spacingBetweenbadgeAndName: LayoutMetric { get }
    var badge: TextStyle { get }
    var badgeContentEdgeInsets: LayoutPaddings { get }
    var badgeCorner: Corner { get }
    var iconSize: LayoutSize { get }
    var horizontalInset: LayoutMetric { get }
    var detailTrailingInset: LayoutMetric { get }
    var verticalInset: LayoutMetric { get }
    var minimumInset: LayoutMetric { get }
    var maximunInset: LayoutMetric { get }
}

struct MnemonicTypeViewLegacyTheme: MnemonicTypeViewTheme {
    let backgroundColor: Color
    let firstShadow: MacaroonUIKit.Shadow
    let secondShadow: MacaroonUIKit.Shadow
    let thirdShadow: MacaroonUIKit.Shadow
    let title: TextStyle
    let detail: TextStyle
    let info: TextStyle
    let spacingBetweenbadgeAndName: LayoutMetric
    let badge: TextStyle
    let badgeContentEdgeInsets: LayoutPaddings
    let badgeCorner: Corner
    let iconSize: LayoutSize
    let horizontalInset: LayoutMetric
    let detailTrailingInset: LayoutMetric
    let verticalInset: LayoutMetric
    let minimumInset: LayoutMetric
    let maximunInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.firstShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow3.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            spread: 1,
            cornerRadii: (12, 12),
            corners: .allCorners
        )
        self.secondShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow2.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: 0,
            cornerRadii: (12, 12),
            corners: .allCorners
        )
        self.thirdShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow1.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: -1,
            cornerRadii: (12, 12),
            corners: .allCorners
        )
        self.title = [
            .textOverflow(FittingText()),
            .font(Typography.bodyMedium()),
            .textColor(Colors.Text.main),
            .textAlignment(.left),
            .isInteractable(false)
        ]
        
        self.spacingBetweenbadgeAndName = 8
        self.badge = [
            .textColor(Colors.Text.gray),
            .textAlignment(.center),
            .textOverflow(SingleLineText()),
            .font(Typography.captionMedium()),
            .backgroundColor(Colors.Layer.grayLighter)
        ]
        self.badgeContentEdgeInsets =  (2, 8, 2, 8)
        self.badgeCorner = Corner(radius: 8)
        
        self.detail = [
            .font(Typography.footnoteRegular()),
            .textColor(Colors.Text.gray),
            .textAlignment(.left),
            .textOverflow(MultilineText(numberOfLines: 0)),
            .isInteractable(false)
        ]

        self.info = [
            .textColor(Colors.Helpers.positive),
            .font(Typography.footnoteMedium()),
            .textAlignment(.left),
            .textOverflow(SingleLineText()),
        ]
        
        self.iconSize = (36, 36)
        self.horizontalInset = 20
        self.detailTrailingInset = -47
        self.verticalInset = 20
        self.minimumInset = 8
        self.maximunInset = 12
    }
}

struct MnemonicTypeViewNewTheme: MnemonicTypeViewTheme {
    let backgroundColor: Color
    let firstShadow: MacaroonUIKit.Shadow
    let secondShadow: MacaroonUIKit.Shadow
    let thirdShadow: MacaroonUIKit.Shadow
    let title: TextStyle
    let detail: TextStyle
    let info: TextStyle
    let spacingBetweenbadgeAndName: LayoutMetric
    let badge: TextStyle
    let badgeContentEdgeInsets: LayoutPaddings
    let badgeCorner: Corner
    let iconSize: LayoutSize
    let horizontalInset: LayoutMetric
    let detailTrailingInset: LayoutMetric
    let verticalInset: LayoutMetric
    let minimumInset: LayoutMetric
    let maximunInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.firstShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow3.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            spread: 1,
            cornerRadii: (12, 12),
            corners: .allCorners
        )
        self.secondShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow2.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: 0,
            cornerRadii: (12, 12),
            corners: .allCorners
        )
        self.thirdShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow1.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: -1,
            cornerRadii: (12, 12),
            corners: .allCorners
        )
        self.title = [
            .textOverflow(FittingText()),
            .font(Typography.bodyMedium()),
            .textColor(Colors.Text.main),
            .textAlignment(.left),
            .isInteractable(false)
        ]
        
        self.spacingBetweenbadgeAndName = 8
        self.badge = [
            .textColor(Colors.Wallet.wallet4Icon),
            .textAlignment(.center),
            .textOverflow(SingleLineText()),
            .font(Typography.captionMedium()),
            .backgroundColor(Colors.Wallet.wallet4)
        ]
        self.badgeContentEdgeInsets =  (2, 8, 2, 8)
        self.badgeCorner = Corner(radius: 8)
        
        self.detail = [
            .font(Typography.footnoteRegular()),
            .textColor(Colors.Text.gray),
            .textAlignment(.left),
            .textOverflow(MultilineText(numberOfLines: 0)),
            .isInteractable(false)
        ]

        self.info = [
            .textColor(Colors.Helpers.positive),
            .font(Typography.footnoteMedium()),
            .textAlignment(.left),
            .textOverflow(SingleLineText()),
        ]
        
        self.iconSize = (36, 36)
        self.horizontalInset = 20
        self.detailTrailingInset = -47
        self.verticalInset = 20
        self.minimumInset = 8
        self.maximunInset = 12
    }
}
