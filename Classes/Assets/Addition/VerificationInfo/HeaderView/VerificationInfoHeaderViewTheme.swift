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

//   VerificationInfoHeaderViewTheme.swift

import Foundation
import MacaroonUIKit

struct VerificationInfoHeaderViewTheme:
    StyleSheet,
    LayoutSheet {
    let backgroundColor: Color

    let closeButton: ButtonStyle
    let closeButtonSize: LayoutSize
    let closeButtonTopPadding: LayoutMetric
    let closeButtonLeadingPadding: LayoutMetric

    let backgroundImage: ImageStyle

    let logoImage: ImageStyle

    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background

        let closeButtonIcon = "icon-close".uiImage.withRenderingMode(.alwaysTemplate)
        self.closeButton = [
            .icon([.normal(closeButtonIcon)]),
            .tintColor(AppColors.Components.Text.main)
        ]
        self.closeButtonSize = (40, 40)
        self.closeButtonTopPadding = 10
        self.closeButtonLeadingPadding = 12

        self.backgroundImage = [
            .contentMode(.bottomLeft)
        ]

        self.logoImage = [
            .contentMode(.scaleAspectFit)
        ]
    }
}
