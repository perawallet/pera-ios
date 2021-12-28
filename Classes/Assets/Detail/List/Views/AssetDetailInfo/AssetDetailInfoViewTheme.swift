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
//   AssetDetailInfoViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AssetDetailInfoViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let yourBalanceTitleLabel: TextStyle
    let balanceLabel: TextStyle
    let assetNameLabel: TextStyle
    let assetIDLabel: TextStyle
    let verifiedImage: ImageStyle
    let separator: Separator

    let topSeparatorTopPadding: LayoutMetric
    let bottomSeparatorTopPadding: LayoutMetric
    let horizontalPadding: LayoutMetric
    let balanceLabelTopPadding: LayoutMetric
    let assetIDLabelTopPadding: LayoutMetric
    let assetIDInfoButtonLeadingPadding: LayoutMetric
    let assetNameLabelTopPadding: LayoutMetric
    let bottomPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.separator = Separator(color: AppColors.Shared.Layer.grayLighter, size: 1)
        self.yourBalanceTitleLabel = [
            .text("accounts-transaction-your-balance".localized),
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.gray),
            .font(Fonts.DMSans.regular.make(15)),
        ]
        self.balanceLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMMono.regular.make(36)),
        ]
        self.assetNameLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMSans.medium.make(15)),
        ]
        self.assetIDLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.gray),
            .font(Fonts.DMSans.regular.make(15)),
        ]
        self.verifiedImage = [
            .image("icon-verified-shield")
        ]
        self.topSeparatorTopPadding = -32
        self.horizontalPadding = 24
        self.balanceLabelTopPadding = 8
        self.assetIDLabelTopPadding = 11
        self.assetIDInfoButtonLeadingPadding = 5
        self.assetNameLabelTopPadding = 65
        self.bottomSeparatorTopPadding = -67
        self.bottomPadding = 33
    }
}
