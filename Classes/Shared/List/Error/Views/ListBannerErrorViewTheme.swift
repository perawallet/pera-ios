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
//   ListBannerErrorViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ListBannerErrorViewTheme: StyleSheet, LayoutSheet {
    let icon: ImageStyle
    let title: TextStyle
    let detail: TextStyle
    let action: ButtonStyle

    let iconSize: LayoutSize
    let horizontalPadding: LayoutMetric
    let verticalPadding: LayoutMetric
    let titleHorizontalPadding: LayoutMetric
    let detailTopPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.icon = [
            .image("icon-info-24"),
            .tintColor(AppColors.Shared.System.background.uiColor),
        ]
        self.title = [
            .textOverflow(SingleLineFittingText()),
            .textAlignment(.left),
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(AppColors.Shared.System.background.uiColor)
        ]
        self.detail = [
            .textOverflow(SingleLineFittingText()),
            .textAlignment(.left),
            .font(Fonts.DMSans.regular.make(13)),
            .textColor(AppColors.Shared.System.background.uiColor)
        ]
        self.action = [
            .title("title-retry".localized),
            .titleColor([.normal(AppColors.Shared.System.background.uiColor)]),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundImage([.normal("list-error-action-bg-icon")])
        ]

        self.iconSize = LayoutSize(w: 24, h: 24)
        self.horizontalPadding = 24
        self.verticalPadding = 20
        self.titleHorizontalPadding = 12
        self.detailTopPadding = 4
    }
}
