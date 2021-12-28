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
//   RewardDetailViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct RewardDetailViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let rewardsRateTitleLabel: TextStyle
    let rewardsRateValueLabel: TextStyle
    let rewardsLabel: TextStyle
    let algoImageView: ImageStyle
    let rewardsValueLabel: TextStyle
    let descriptionLabel: TextStyle
    let FAQLabel: TextStyle
    let FAQLabelLinkTextColor: Color
    let separator: Separator

    let separatorTopPadding: LayoutMetric
    let rewardsRateTitleLabelTopPadding: LayoutMetric
    let horizontalPadding: LayoutMetric
    let rewardsRateValueLabelTopPadding: LayoutMetric
    let algoImageViewTopPadding: LayoutMetric
    let rewardsLabelLeadingPadding: LayoutMetric
    let algoImageViewSize: LayoutSize
    let descriptionLabelTopPadding: LayoutMetric
    let FAQLabelTopPadding: LayoutMetric
    let bottomInset: LayoutMetric

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
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMMono.regular.make(19)),
        ]
        self.rewardsLabel = [
            .text("rewards-title".localized),
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.gray),
            .font(Fonts.DMSans.regular.make(13)),
        ]
        self.algoImageView = [
            .image("icon-algo-circle-green"),
            .contentMode(.scaleAspectFit)
        ]
        self.rewardsValueLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMMono.regular.make(19)),
        ]
        self.descriptionLabel = [
            .text("rewards-detail-subtitle".localized),
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMSans.regular.make(15)),
            .isInteractable(true),
            .textAlignment(.left),
            .textOverflow(FittingText())
        ]
        self.FAQLabel = [
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMSans.regular.make(15)),
            .isInteractable(true),
            .textAlignment(.left),
            .textOverflow(FittingText())
        ]
        self.FAQLabelLinkTextColor = AppColors.Components.Link.primary

        self.separatorTopPadding = -68
        self.horizontalPadding = 24
        self.rewardsRateValueLabelTopPadding = 8
        self.rewardsLabelLeadingPadding = 12
        self.rewardsRateTitleLabelTopPadding = 28
        self.algoImageViewTopPadding = 10
        self.algoImageViewSize = (24, 24)
        self.descriptionLabelTopPadding = 65
        self.FAQLabelTopPadding = 12
        self.bottomInset = 16
    }
}
