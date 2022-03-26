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

//   GenericBannerViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct GenericBannerViewTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    var title: TextStyle
    var subtitle: TextStyle
//    var action: ButtonStyle
//    var close: ButtonStyle
    
    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(AppColors.Components.Banner.background)
        ]
        self.title = [
            .font(Fonts.DMSans.medium.make(15)),
            .textOverflow(FittingText()),
            .textColor(AppColors.Components.Banner.text)
        ]
        self.subtitle = [
            .font(Fonts.DMSans.regular.make(13)),
            .textOverflow(FittingText()),
            .textColor(AppColors.Components.Banner.text)
        ]
//        self.titleTopPadding = 8
//        self.infoAction = [
//            .icon([ .normal("icon-info-20".templateImage) ])
//        ]
//        self.value = [
//            .textColor(AppColors.Components.Text.main.uiColor),
//            .textOverflow(SingleLineFittingText())
//        ]
//        self.algoHoldings = HomePortfolioItemViewTheme()
//        self.assetHoldings = HomePortfolioItemViewTheme()
//        self.spacingBetweenTitleAndInfoAction = 8
//        self.spacingBetweenTitleAndValue = 8
//        self.spacingBetweenValueAndHoldings = 24
//        self.minSpacingBetweenAlgoHoldingsAndAssetHoldings = 8
//        self.buyAlgoButton = ButtonPrimaryTheme(family)
//        self.buyAlgoButtonHeight = 52
//        self.buyAlgoButtonMargin = (44, .noMetric, .noMetric, .noMetric)
    }
}
