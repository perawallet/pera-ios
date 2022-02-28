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

//   CollectiblePreviewViewTheme.swift

import MacaroonUIKit

struct CollectiblePreviewViewTheme:
    LayoutSheet,
    StyleSheet {
    let iconCorner: Corner
    let primaryAssetTitle: TextStyle
    let secondaryAssetTitle: TextStyle
    var accessory: TextStyle

    let contentMinWidthRatio: LayoutMetric
    let minSpacingBetweenContentAndSecondaryContent: LayoutMetric
    let horizontalPadding: LayoutMetric
    let iconSize: LayoutSize

    init(_ family: LayoutFamily) {
        iconCorner = Corner(radius: 4)
        primaryAssetTitle = [
            .textOverflow(SingleLineText()),
            .textColor(AppColors.Components.Text.main),
        ]
        secondaryAssetTitle = [
            .textOverflow(SingleLineText()),
            .textColor(AppColors.Components.Text.grayLighter),
        ]
        accessory = [
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.gray)
        ]

        iconSize = (40, 40)
        contentMinWidthRatio = 0.15
        minSpacingBetweenContentAndSecondaryContent = 8
        horizontalPadding = 16
    }
}
