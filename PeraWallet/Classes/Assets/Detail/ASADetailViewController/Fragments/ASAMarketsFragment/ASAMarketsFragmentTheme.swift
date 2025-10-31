// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ASAMarketsFragmentTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ASAMarketsFragmentTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    var contextEdgeInsets: NSDirectionalEdgeInsets
    var profile: ASAProfileViewTheme
    var marketInfo: ASADetailMarketViewTheme
    var statistics: AssetStatisticsSectionViewTheme
    var about: AssetAboutSectionViewTheme
    var verificationTier: AssetVerificationInfoViewTheme
    var description: ShowMoreViewTheme
    
    var socialMedia: AssetSocialMediaGroupedListItemButtonTheme
    var reportAction: ListItemButtonTheme
    
    var spacingBetweenProfileAndMarket: CGFloat
    var spacingBetweenMarketAndStatistics: CGFloat
    var spacingBetweenStatisticsAndAbout: CGFloat
    var spacingBetweenSeparatorAndAbout: CGFloat
    var spacingBetweenSectionsAndVerificationTier: CGFloat
    var spacingBetweenVerificationTierAndFirstSection: CGFloat
    var spacingBetweenVerificationTierAndSections: CGFloat
    var spacingBetweenSeparatorAndDescription: CGFloat
    var spacingBetweenSeparatorAndSocialMedia: CGFloat
    var spacingBetweenSeparatorAndReportAction: CGFloat
    var spacingBetweenSectionsAndReportAction: CGFloat
    var sectionSeparator: Separator
    var spacingBetweenSections: CGFloat

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.contextEdgeInsets = .init(top: 36, leading: 24, bottom: 8, trailing: 24)
        self.profile = ASAProfileViewTheme(family)
        self.marketInfo = ASADetailMarketViewTheme()
        self.statistics = AssetStatisticsSectionViewTheme(family)
        self.about = AssetAboutSectionViewTheme(family)
        self.verificationTier = AssetVerificationInfoViewTheme(family)
        self.description = ShowMoreViewTheme(numberOfLinesLimit: 4, family: family)
        self.socialMedia = AssetSocialMediaGroupedListItemButtonTheme(family)
        var reportAction = ListItemButtonTheme(family)
        reportAction.configureForAssetSocialMediaView()
        self.reportAction = reportAction
        self.sectionSeparator = Separator(color: Colors.Layer.grayLighter, position: .top((0, 0)))
        
        self.spacingBetweenProfileAndMarket = 34
        self.spacingBetweenMarketAndStatistics = 38
        self.spacingBetweenStatisticsAndAbout = 62
        self.spacingBetweenSeparatorAndAbout = 26
        self.spacingBetweenSectionsAndVerificationTier = 22
        self.spacingBetweenVerificationTierAndFirstSection = 24
        self.spacingBetweenVerificationTierAndSections = 60
        self.spacingBetweenSeparatorAndDescription = 36
        self.spacingBetweenSeparatorAndSocialMedia = 36
        self.spacingBetweenSeparatorAndReportAction = 26
        self.spacingBetweenSectionsAndReportAction = 62
        self.spacingBetweenSections = 72
    }
}
