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
//   AccountPortfolioErrorViewTheme.swift

import MacaroonUIKit

struct AccountPortfolioErrorViewTheme: StyleSheet, LayoutSheet {
    let icon: ImageStyle
    let message: TextStyle
    let separator: Separator

    let horizontalInset: LayoutMetric
    let iconSize: LayoutSize
    let messageLeadingInset: LayoutMetric
    let separatorTopPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.icon = [
            .image("icon-red-warning")
        ]
        self.message = [
            .textOverflow(FittingText()),
            .textAlignment(.left),
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(AppColors.Shared.Helpers.negative.uiColor),
            .text("account-listing-error-message".localized)
        ]
        self.separator = Separator(color: AppColors.Shared.Layer.grayLighter, size: 1)

        self.horizontalInset = 24
        self.iconSize = (24, 24)
        self.messageLeadingInset = 8
        self.separatorTopPadding = 24
    }
}
