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

//   ASAProfileViewTheme.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import UIKit

struct ASAProfileViewTheme:
    StyleSheet,
    LayoutSheet {
    var icon: URLImageViewStyleSheet & URLImageViewLayoutSheet
    var expandedIconSize: LayoutSize
    var compressedIconSize: LayoutSize
    var expandedSpacingBetweenIconAndTitle: LayoutMetric
    var compressedSpacingBetweenIconAndTitle: LayoutMetric
    var name: RightAccessorizedLabelStyle
    var titleSeparator: TextStyle
    var titleSeparatorContentEdgeInsets: LayoutPaddings
    var id: TextStyle
    var spacingBetweenTitleAndPrimaryValue: LayoutMetric
    var primaryValue: TextStyle
    var spacingBetweenPrimaryValueAndSecondValue: LayoutMetric
    var secondaryValue: TextStyle

    init(_ family: LayoutFamily) {
        self.icon = URLImageViewAssetTheme()
        self.expandedIconSize = (40, 40)
        self.compressedIconSize = (20, 20)

        self.expandedSpacingBetweenIconAndTitle = 20
        self.compressedSpacingBetweenIconAndTitle = 8

        var name = RightAccessorizedLabelStyle()
        name.text = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText())
        ]
        name.accessoryContentOffset = (6, 0)
        self.name = name

        self.titleSeparator = [
            .textColor(Colors.Text.grayLighter),
            .textOverflow(SingleLineText())
        ]
        self.titleSeparatorContentEdgeInsets = (0, 8, 0, 8)

        self.id = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText())
        ]

        self.spacingBetweenTitleAndPrimaryValue = 8
        self.primaryValue = [
            .textColor(Colors.Text.main),
            .textOverflow(SingleLineFittingText())
        ]

        self.spacingBetweenPrimaryValueAndSecondValue = 8
        self.secondaryValue = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineFittingText())
        ]
    }
}
