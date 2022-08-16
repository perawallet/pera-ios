// Copyright 2022 Pera Wallet, LDA

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
//   RewardsInfoViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct RewardsInfoViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let rewardImage: ImageStyle
    let rewardsLabel: TextStyle
    let rewardsValueLabel: TextStyle
    let infoButton: ButtonStyle

    let containerCorner: Corner
    let containerBorder: Border
    let containerFirstShadow: MacaroonUIKit.Shadow
    let containerSecondShadow: MacaroonUIKit.Shadow
    let containerThirdShadow: MacaroonUIKit.Shadow

    let imageVerticalInset: LayoutMetric
    let imageHorizontalInset: LayoutMetric
    let horizontalPadding: LayoutMetric
    let rewardsValueLabelTopPadding: LayoutMetric
    let minimumHorizontalInset: LayoutMetric
    let bottomPadding: LayoutMetric
    let rewardsLabelLeadingPadding: LayoutMetric
    let infoButtonSize: LayoutSize

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.rewardImage = [
            .image("icon-reward-info"),
            .contentMode(.center)
        ]
        self.rewardsLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(Colors.Text.gray),
            .font(Fonts.DMSans.regular.make(13)),
        ]
        self.rewardsValueLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMMono.regular.make(13)),
        ]
        self.infoButton = [
            .icon([.normal("icon-info-gray")])
        ]

        // <todo>: Remove duplication of shadow
        self.containerCorner = Corner(radius: 4)
        self.containerBorder = Border(color: Colors.Shadows.Cards.shadow1.uiColor, width: 1)
        self.containerFirstShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow1.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            fillColor: Colors.Defaults.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
        self.containerSecondShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow2.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            fillColor: Colors.Defaults.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
        self.containerThirdShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow3.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            fillColor: Colors.Defaults.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )

        self.imageVerticalInset = 16
        self.imageHorizontalInset = 20
        self.horizontalPadding = 16
        self.rewardsValueLabelTopPadding = 4
        self.minimumHorizontalInset = 4
        self.bottomPadding = 14
        self.rewardsLabelLeadingPadding = 16
        self.infoButtonSize = (40, 40)
    }
}
