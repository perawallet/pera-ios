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
//   AccountPreviewViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AccountPreviewViewTheme: StyleSheet, LayoutSheet {
    let accountName: TextStyle
    let assetAndNFTs: TextStyle
    let assetValue: TextStyle
    let secondaryAssetValue: TextStyle
    let errorImage: ImageStyle
    
    let horizontalPadding: LayoutMetric
    let verticalPadding: LayoutMetric
    let errorImageSize: LayoutSize

    init(_ family: LayoutFamily) {
        self.accountName = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMSans.regular.make(15))
        ]
        self.assetAndNFTs = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.grayLighter),
            .font(Fonts.DMSans.regular.make(13))
        ]
        self.assetValue = [
            .textAlignment(.right),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMMono.regular.make(15))
        ]
        self.secondaryAssetValue = [
            .textAlignment(.right),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.grayLighter),
            .font(Fonts.DMMono.regular.make(13))
        ]
        self.errorImage = [
            .image("icon-red-warning")
        ]

        self.horizontalPadding = 16
        self.verticalPadding = 16
        self.errorImageSize = (24, 24)
    }
}
