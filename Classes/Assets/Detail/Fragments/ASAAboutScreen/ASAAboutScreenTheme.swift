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
    var loading: ASAAboutLoadingViewTheme
    var contextEdgeInsets: NSDirectionalEdgeInsets
    var statistics: AssetStatisticsSectionViewTheme
    var spacingBetweenStatisticsAndSeparator: CGFloat
    var spacingBetweenStatisticsAndAbout: CGFloat
    var about: AssetAboutSectionViewTheme
    var spacingBetweenAboutAndSeparator: CGFloat
    var verificationTier: AssetVerificationInfoViewTheme
    var spacingBetweenVerificationTierAndSeparator: CGFloat
    var spacingBetweenVerificationTierAndSections: CGFloat
    var description: ShowMoreViewTheme
    var spacingBetweenDescriptionAndSeparator: CGFloat
    var socialMedia: AssetSocialMediaGroupedListItemButtonTheme
    var spacingBetweenSocialMediaAndSeparator: CGFloat
    var reportAction: ListItemButtonTheme
    var reportActionSeparator: Separator
    var spacingBetweenSeparatorAndReportAction: CGFloat
    var spacingBetweenSectionsAndReportAction: CGFloat
    var sectionSeparator: Separator
    var spacingBetweenSections: CGFloat

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.loading = ASAAboutLoadingViewTheme()
        self.contextEdgeInsets = .init(top: 36, leading: 24, bottom: 8, trailing: 24)
        self.statistics = AssetStatisticsSectionViewTheme(family)
        self.spacingBetweenStatisticsAndSeparator = 36
        self.spacingBetweenStatisticsAndAbout = 62
        self.about = AssetAboutSectionViewTheme(family)
        self.spacingBetweenAboutAndSeparator = 26
        self.verificationTier = AssetVerificationInfoViewTheme(family)
        self.spacingBetweenVerificationTierAndSeparator = 20
        self.spacingBetweenVerificationTierAndSections = 60
        self.description = ShowMoreViewTheme(numberOfLinesLimit: 4, family: family)
        self.spacingBetweenDescriptionAndSeparator = 34
        self.socialMedia = AssetSocialMediaGroupedListItemButtonTheme(family)
        self.spacingBetweenSocialMediaAndSeparator = 32

        var reportAction = ListItemButtonTheme(family)
        reportAction.configureForAssetSocialMediaView()
        self.reportAction = reportAction
        self.reportActionSeparator =
            Separator(color: Colors.Layer.grayLighter, position: .top((0, 0)))
        self.spacingBetweenSeparatorAndReportAction = 26
        self.spacingBetweenSectionsAndReportAction = 62

        self.sectionSeparator = Separator(color: Colors.Layer.grayLighter)
        self.spacingBetweenSections = 72
    }
}
