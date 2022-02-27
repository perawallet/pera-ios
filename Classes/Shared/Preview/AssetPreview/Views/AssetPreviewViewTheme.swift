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
//   AssetPreviewViewTheme.swift

import MacaroonUIKit

struct AssetPreviewViewTheme:
    LayoutSheet,
    StyleSheet {
    let verifiedIcon: ImageStyle
    let primaryAssetTitle: TextStyle
    let secondaryAssetTitle: TextStyle
    var primaryAssetValue: TextStyle
    var secondaryAssetValue: TextStyle

    let contentMinWidthRatio: LayoutMetric
    let minSpacingBetweenContentAndSecondaryContent: LayoutMetric
    let verifiedIconContentEdgeInsets: LayoutOffset
    let imageSize: LayoutSize
    let horizontalPadding: LayoutMetric
    let verticalPadding: LayoutMetric
    let secondaryImageLeadingPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.contentMinWidthRatio = 0.1
        self.minSpacingBetweenContentAndSecondaryContent = 8
        self.verifiedIconContentEdgeInsets = (8, 0)
        self.verifiedIcon = [
            .contentMode(.right)
        ]
        self.primaryAssetTitle = [
            .textOverflow(SingleLineText()),
            .textColor(AppColors.Components.Text.main),
        ]
        self.secondaryAssetTitle = [
            .textOverflow(SingleLineText()),
            .textColor(AppColors.Components.Text.grayLighter),
        ]
        self.primaryAssetValue = [
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.main),
        ]
        self.secondaryAssetValue = [
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.grayLighter),
        ]

        self.imageSize = (40, 40)
        self.horizontalPadding = 16
        self.secondaryImageLeadingPadding = 8
        self.verticalPadding = 16
    }
}

extension AssetPreviewViewTheme {
    mutating func configureForAssetPreviewAddition() {
        primaryAssetValue = primaryAssetValue.modify(
            [ .textOverflow(SingleLineFittingText()), .textColor(AppColors.Components.Text.gray) ]
        )
        secondaryAssetValue = secondaryAssetValue.modify( [ ] )
    }
}
