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
    var verificationTier: AssetVerificationInfoViewTheme
    var description: ShowMoreViewTheme
    var spacingBetweenVerificationTierAndSeparator: CGFloat
    var sectionSeparator: Separator
    var spacingBetweenSectionAndSeparator: CGFloat
    var spacingBetweenSections: CGFloat

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.contextEdgeInsets = .init(top: 36, leading: 24, bottom: 8, trailing: 24)
        self.statistics = AssetStatisticsSectionViewTheme(family)
        self.verificationTier = AssetVerificationInfoViewTheme(family)
        self.description = ShowMoreViewTheme(family)
        self.spacingBetweenVerificationTierAndSeparator = 20
        self.sectionSeparator = Separator(color: Colors.Layer.grayLighter, position: .bottom((24, 24)))
        self.spacingBetweenSectionAndSeparator = 36
        self.spacingBetweenSections = 72
    }
}
