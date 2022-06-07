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
//   HomeLoadingViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct HomeLoadingViewTheme:
    StyleSheet,
    LayoutSheet {
    var portfolioText: EditText
    var portfolioMargin: LayoutMargins
    var infoAction: ButtonStyle
    var spacingBetweenTitleAndInfoAction: LayoutMetric
    var portfolioLoadingMargin: LayoutMargins
    var portfolioLoadingSize: LayoutSize
    var portfolioCurrencyLoadingMargin: LayoutMargins
    var portfolioCurrencyLoadingSize: LayoutSize

    var loadingCorner: Corner

    var quickActionsTheme: QuickActionsViewTheme
    var quickActionsMargin: LayoutMargins

    var accountsLabelStyle: TextStyle
    var accountsLabelMargin: LayoutMargins

    var accountLoadingMargin: LayoutMargins
    var accountLoadingHeight: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        self.portfolioText = .attributedString(
            "portfolio-title"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineHeightMultiple(lineHeightMultiplier)
                    ]),
                    .textColor(AppColors.Components.Text.gray)
                ])
            )

        self.portfolioMargin = (8, 24, .noMetric, .noMetric)
        self.infoAction = [
            .icon([ .normal("icon-info-20".templateImage) ]),
            .tintColor(AppColors.Components.Text.gray)
        ]
        self.spacingBetweenTitleAndInfoAction = 8
        self.portfolioLoadingMargin = (10, .noMetric, .noMetric, .noMetric)
        self.portfolioLoadingSize = (181, 48)
        self.portfolioCurrencyLoadingMargin = (8, .noMetric, .noMetric, .noMetric)
        self.portfolioCurrencyLoadingSize = (97, 20)

        self.loadingCorner = Corner(radius: 4)

        self.quickActionsTheme = QuickActionsViewTheme(family)
        self.quickActionsMargin = (43, 24, .noMetric, 24)

        self.accountsLabelStyle = [
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(AppColors.Components.Text.main),
            .textOverflow(FittingText()),
            .text("accounts-title".localized)
        ]
        self.accountsLabelMargin = (80, 24, .noMetric, 24)
        self.accountLoadingMargin = (4, 24, .noMetric, 24)
        self.accountLoadingHeight = 72
    }

    func accountLabelTopInset() -> LayoutMetric {
        return 214
    }

    func quickActionsBottomInset() -> LayoutMetric {
        return 36
    }
}
