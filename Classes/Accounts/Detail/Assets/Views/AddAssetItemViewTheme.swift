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
//   AddAssetItemViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AddAssetItemViewTheme: StyleSheet, LayoutSheet {
    let icon: ImageStyle
    let title: TextStyle

    let iconLeadingInset: LayoutMetric
    let iconSize: LayoutSize
    let verticalInset: LayoutMetric
    let titleHorizontalPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.icon = [
            .contentMode(.scaleAspectFit),
            .image("add-icon-40")
        ]
        self.title = [
            .textOverflow(FittingText()),
            .textAlignment(.left),
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(AppColors.Shared.System.background.uiColor),
            .text("title-add-asset".localized)
        ]

        self.iconLeadingInset = 24
        self.iconSize = LayoutSize(w: 40, h: 40)
        self.verticalInset = 16
        self.titleHorizontalPadding = 16
    }
}
