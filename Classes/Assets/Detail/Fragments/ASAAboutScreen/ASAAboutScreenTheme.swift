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

//   ASAAboutScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ASAAboutScreenTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    var contextEdgeInsets: NSDirectionalEdgeInsets
    var statistics: AssetStatisticsSectionViewTheme
    var spacingBetweenStatisticsAndSeparator: CGFloat
    var verificationTier: AssetVerificationInfoViewTheme
    var spacingBetweenVerificationTierAndSeparator: CGFloat
    var spacingBetweenVerificationTierAndSections: CGFloat
    var description: ShowMoreViewTheme
    var spacingBetweenDescriptionAndSeparator: CGFloat
    var socialMediaGroupedList: AssetSocialMediaGroupedListItemButtonTheme
    var spacingBetweenSocialMediaAndSeparator: CGFloat
    var spacingBetweenSocialMediaAndAsaReport: CGFloat
    var asaReport: ListItemButtonTheme
    var sectionSeparator: Separator
    var spacingBetweenSections: CGFloat

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.contextEdgeInsets = .init(top: 36, leading: 24, bottom: 8, trailing: 24)
        self.statistics = AssetStatisticsSectionViewTheme(family)
        self.spacingBetweenStatisticsAndSeparator = 36
        self.verificationTier = AssetVerificationInfoViewTheme(family)
        self.spacingBetweenVerificationTierAndSeparator = 20
        self.spacingBetweenVerificationTierAndSections = 60
        self.description = ShowMoreViewTheme(numberOfLinesLimit: 4, family: family)
        self.spacingBetweenDescriptionAndSeparator = 34
        self.socialMediaGroupedList = AssetSocialMediaGroupedListItemButtonTheme(family)
        self.spacingBetweenSocialMediaAndSeparator = 32
        self.spacingBetweenSocialMediaAndAsaReport = 26
        self.asaReport = ListItemButtonTheme(family)
        self.sectionSeparator = Separator(color: Colors.Layer.grayLighter)
        self.spacingBetweenSections = 72
    }
}
