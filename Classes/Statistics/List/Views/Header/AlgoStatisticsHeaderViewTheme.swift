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
//   AlgoStatisticsHeaderViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AlgoStatisticsHeaderViewTheme: StyleSheet, LayoutSheet {
    let amountLabel: TextStyle
    let dateLabel: TextStyle
    let arrowDown: ImageStyle
    let valueChangeViewTheme: AlgoStatisticsValueChangeViewTheme
    let stackViewTopPadding: LayoutMetric 
    let horizontalSpacing: LayoutMetric
    let dateStackViewSpacing: LayoutMetric

    init(_ family: LayoutFamily) {
        self.amountLabel = [
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMMono.regular.make(36)),
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText())
        ]
        self.dateLabel = [
            .textColor(AppColors.Components.Text.gray),
            .font(Fonts.DMSans.regular.make(15)),
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText())
        ]
        self.arrowDown = [
            .image("icon-arrow-down-grey")
        ]
        self.valueChangeViewTheme = AlgoStatisticsValueChangeViewTheme()

        self.horizontalSpacing = 12
        self.stackViewTopPadding = 10
        self.dateStackViewSpacing = 5
    }
}
