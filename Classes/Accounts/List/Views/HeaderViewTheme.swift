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
//   HeaderViewTheme.swift

import MacaroonUIKit
import CoreGraphics

struct HeaderViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let titleLabel: TextStyle
    let testNetTitleLabel: TextStyle
    let testNetTitleLabelCorner: Corner

    let testNetLabelOffset: LayoutMetric
    let rightButtonPaddings: LayoutPaddings
    let titlePaddings: LayoutPaddings
    let testNetLabelSize: LayoutSize

    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.titleLabel = [
            .font(Fonts.DMSans.medium.make(32)),
            .textAlignment(.left),
            .textColor(AppColors.Components.Text.main)
        ]
        self.testNetTitleLabel = [
            .font(Fonts.DMSans.medium.make(10)),
            .textAlignment(.center),
            .textColor(AppColors.Components.Text.main),
            .text("title-testnet".localized),
            .backgroundColor(Colors.General.testNetBanner)
        ]
        self.testNetTitleLabelCorner = Corner(radius: 12)
        self.rightButtonPaddings = (2, .noMetric, .noMetric, 12)
        self.titlePaddings = (46, 24, 10, 24)
        self.testNetLabelSize = (63, 24)
        self.testNetLabelOffset = 8
    }
}
