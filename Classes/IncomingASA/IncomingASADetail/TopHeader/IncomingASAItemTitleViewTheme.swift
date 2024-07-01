// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   IncomingASAItemTitleViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct IncomingASAItemTitleViewTheme: StyleSheet, LayoutSheet {
    let primaryTitle: TextStyle
    let primaryTitleAccessory: ImageStyle
    let primaryTitleAccessoryContentEdgeInsets: LayoutOffset
    let secondaryTitle: TextStyle
    var secondaryTitleWidth: LayoutMetric
    let secondSecondaryTitle: TextStyle
    let titleHeight: LayoutMetric
    let spacingBetweenPrimaryAndSecondaryTitles: LayoutMetric
    let titleEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        self.primaryTitle = [
            .textColor(Colors.Text.mainDark)
        ]
        self.primaryTitleAccessory = [
            .contentMode(.right),
        ]
        self.primaryTitleAccessoryContentEdgeInsets = (6, 0)
        
        self.secondaryTitle = [
            .textColor(Colors.Button.Square.secondaryIcon),
            .font(Typography.captionMedium()),
            .backgroundColor(Colors.Button.Ghost.focusBackgroundDark)
        ]
        self.secondaryTitleWidth = 72
        self.secondSecondaryTitle = [
            .textColor(Colors.Button.Square.secondaryIcon),
            .font(Typography.captionMedium()),
            .backgroundColor(Colors.Button.Ghost.focusBackgroundDark)
        ]
        self.titleHeight = 20
        self.spacingBetweenPrimaryAndSecondaryTitles = 0
        self.titleEdgeInsets = (0, 6, 0, 6)
    }
}
