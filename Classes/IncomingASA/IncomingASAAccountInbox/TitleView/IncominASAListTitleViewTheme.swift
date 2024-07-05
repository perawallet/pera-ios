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

//   IncominAsaTitleViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct IncominASAListTitleViewTheme: StyleSheet, LayoutSheet {
    var primaryTitle: TextStyle
    var primaryTitleAccessory: ImageStyle
    var primaryTitleAccessoryContentEdgeInsets: LayoutOffset
    var secondaryTitle: TextStyle
    var secondSecondaryTitle: TextStyle
    var spacingBetweenPrimaryAndSecondaryTitles: LayoutMetric
    var titleEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        self.primaryTitle = [
            .textColor(Colors.Text.mainDark),
            .font(Typography.bodyMedium())
        ]
        self.primaryTitleAccessory = [
            .contentMode(.right),
        ]
        self.primaryTitleAccessoryContentEdgeInsets = (6, 0)
        self.secondaryTitle = [
            .textColor(Colors.Button.Square.secondaryIcon),
            .font(Typography.captionMedium()),
            .backgroundColor(Colors.Button.Ghost.focusBackground)
        ]
        self.secondSecondaryTitle = [
            .textColor(Colors.Button.Square.secondaryIcon),
            .font(Typography.captionMedium()),
            .backgroundColor(Colors.Button.Ghost.focusBackground)
        ]
        self.spacingBetweenPrimaryAndSecondaryTitles = 0
        self.titleEdgeInsets = (2, 6, 4, 6)
    }
}
