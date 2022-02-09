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
//   AlgoStatisticsHeaderViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AlgoStatisticsHeaderViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let amountLabel: TextStyle
    let dateLabel: TextStyle
    let valueChangeViewTheme: AlgoStatisticsValueChangeViewTheme

    let loadingCorner: Corner
    let valueChangeLoadingViewTopPadding: LayoutMetric
    let valueChangeLoadingViewSize: LayoutSize
    
    let topPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = UIColor.clear
        self.amountLabel = [
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMMono.regular.make(36)),
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText())
        ]
        self.dateLabel = [
            .textColor(AppColors.Components.Text.gray),
            .font(Fonts.DMSans.regular.make(13)),
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText())
        ]
        self.valueChangeViewTheme = AlgoStatisticsValueChangeViewTheme()

        self.loadingCorner = Corner(radius: 4)
        self.valueChangeLoadingViewTopPadding = 12
        self.valueChangeLoadingViewSize = (59, 20)

        self.topPadding = 10
    }
}
