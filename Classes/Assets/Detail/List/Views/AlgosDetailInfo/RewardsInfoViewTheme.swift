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
//   RewardsInfoViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct RewardsInfoViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let rewardsRateTitleLabel: TextStyle
    let rewardsRateValueLabel: TextStyle
    let rewardsLabel: TextStyle
    let rewardsValueLabel: TextStyle
    let separator: Separator
    let infoButton: ButtonStyle

    let separatorTopPadding: LayoutMetric
    let rewardsRateTitleLabelTopPadding: LayoutMetric
    let horizontalPadding: LayoutMetric
    let rewardsRateValueLabelTopPadding: LayoutMetric
    let descriptionLabelTopPadding: LayoutMetric
    let minimumHorizontalInset: LayoutMetric
    let bottomPadding: LayoutMetric
    let verticalSeparatorLeadingPadding: LayoutMetric
    let rewardsLabelLeadingPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.separator = Separator(color: AppColors.Shared.Layer.grayLighter, size: 1)
        self.rewardsRateTitleLabel = [
            .text("rewards-rate".localized),
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.gray),
            .font(Fonts.DMSans.regular.make(13)),
        ]
        self.rewardsRateValueLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Shared.Helpers.positive),
            .font(Fonts.DMMono.regular.make(13)),
        ]
        self.rewardsLabel = [
            .text("rewards-title".localized),
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.gray),
            .font(Fonts.DMSans.regular.make(13)),
        ]
        self.rewardsValueLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMMono.regular.make(13)),
        ]
        self.infoButton = [
            .icon([.normal("icon-info-gray")])
        ]

        self.separatorTopPadding = -68
        self.horizontalPadding = 16
        self.rewardsRateValueLabelTopPadding = 4
        self.rewardsRateTitleLabelTopPadding = 14
        self.descriptionLabelTopPadding = 65
        self.minimumHorizontalInset = 4
        self.bottomPadding = 14
        self.verticalSeparatorLeadingPadding = 26
        self.rewardsLabelLeadingPadding = 47
    }
}
