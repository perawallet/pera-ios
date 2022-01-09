// Copyright 2019 Algorand, Inc.

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
//   AccountPortfolioViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AccountPortfolioViewTheme: StyleSheet, LayoutSheet {
    let algoHoldingsTitle: TextStyle
    let algoHoldingsValue: ButtonStyle
    let assetHoldingsTitle: TextStyle
    let assetHoldingsValue: TextStyle

    let horizontalInset: LayoutMetric
    let algosValueHorizontalInset: LayoutMetric
    let titleTopPadding: LayoutMetric
    let portfolioTopPadding: LayoutMetric
    let holdingsTopPadding: LayoutMetric
    let valuesTopPadding: LayoutMetric
    let valueTrailingInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.algoHoldingsTitle = [
            .textOverflow(SingleLineFittingText()),
            .textAlignment(.left),
            .text("portfolio-algo-holdings-title".localized),
            .font(Fonts.DMSans.regular.make(15)),
            .textColor(AppColors.Components.Text.gray.uiColor)
        ]
        self.algoHoldingsValue = [
            .font(Fonts.DMSans.regular.make(15)),
            .titleColor([.normal(AppColors.Components.Text.main.uiColor)]),
            .icon([.normal("icon-algo-circle-green-24")])
        ]
        self.assetHoldingsTitle = [
            .textOverflow(SingleLineFittingText()),
            .textAlignment(.left),
            .text("portfolio-asset-holdings-title".localized),
            .font(Fonts.DMSans.regular.make(15)),
            .textColor(AppColors.Components.Text.gray.uiColor)
        ]
        self.assetHoldingsValue = [
            .textOverflow(SingleLineFittingText()),
            .textAlignment(.left),
            .font(Fonts.DMSans.regular.make(15)),
            .textColor(AppColors.Components.Text.main.uiColor)
        ]

        self.horizontalInset = 24
        self.algosValueHorizontalInset = 30
        self.titleTopPadding = 24
        self.portfolioTopPadding = 32
        self.holdingsTopPadding = 24
        self.valuesTopPadding = 12
        self.valueTrailingInset = 40
    }
}
