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

//   ASAMarketsFragmentMarketViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ASAMarketsFragmentMarketViewTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    var backgroundCorner: Corner
    var spacingBetweenItemsInStack: LayoutMetric
    var titleLeading: LayoutMetric
    var subtitleTrailing: LayoutMetric
    var accessoryIconSize: LayoutSize
    var accessoryIconTrailing: LayoutMetric
    var titleStyle: TextStyle
    var subtitleStyle: TextStyle
    var detailImage: ImageStyle
    let height: LayoutMetric

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Layer.grayLighter)
        ]
        self.backgroundCorner = Corner(radius: 16)
        self.spacingBetweenItemsInStack = 8
        self.titleLeading = 16
        self.subtitleTrailing = -7
        self.accessoryIconSize = (20, 20)
        self.accessoryIconTrailing = 24
        self.titleStyle = [
            .text(String(localized: "view-more-details-discover-title")),
            .textColor(Colors.Text.gray),
            .font(Typography.footnoteRegular())
        ]
        self.subtitleStyle = [
            .text(String(localized: "asset-detail-markets-title")),
            .textColor(Colors.Text.main),
            .font(Typography.footnoteMedium()),
            .textAlignment(.right)
        ]
        self.detailImage = [
            .image("icon-arrow-24")
        ]
        self.height = 48
    }
}
