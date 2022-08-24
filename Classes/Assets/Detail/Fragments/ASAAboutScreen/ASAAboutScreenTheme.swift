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
    var about: AssetAboutSectionViewTheme
    var verificationTier: AssetVerificationInfoViewTheme
    var description: ShowMoreViewTheme
    var socialMedia: AssetSocialMediaGroupedListItemButtonTheme
    var spacingBeforeReportAction: LayoutMetric
    var reportAction: ListItemButtonTheme
    var sectionSeparator: Separator
    var spacingBetweenSections: CGFloat

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.loading = ASAAboutLoadingViewTheme()
        self.contextEdgeInsets = .init(top: 36, leading: 24, bottom: 8, trailing: 24)
        self.statistics = AssetStatisticsSectionViewTheme(family)
        self.about = AssetAboutSectionViewTheme(family)
        self.verificationTier = AssetVerificationInfoViewTheme(family)
        self.description = ShowMoreViewTheme(family)
        self.description = ShowMoreViewTheme(numberOfLinesLimit: 4, family: family)
        self.socialMedia = AssetSocialMediaGroupedListItemButtonTheme(family)

        self.spacingBeforeReportAction = 27
        var reportAction = ListItemButtonTheme(family)
        reportAction.configureForAssetSocialMediaView()
        self.reportAction = reportAction

        self.sectionSeparator = Separator(color: Colors.Layer.grayLighter, position: .bottom((0, 0)))
        self.spacingBetweenSections = 36
    }
}
