// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   MenuListCardEnabledViewTheme.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import UIKit

struct MenuListCardEnabledViewTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    var contentViewRadius: LayoutMetric
    var title: TextStyle
    var titleHorizontalPadding: LayoutMetric
    var description: TextStyle
    var spaceBetweenTitleAndDescription: LayoutMetric
    var iconHorizontalPadding: LayoutMetric
    var iconVerticalPadding: LayoutMetric
    var image: ImageStyle
    var imageVerticalPadding: LayoutMetric
    var cardView: ImageStyle
    var cardViewPaddings: LayoutPaddings
    var cardNumber: TextStyle
    var cardBalance: TextStyle
    var arrow: ImageStyle
    var action: ButtonStyle
    var actionHeight: LayoutMetric
    var separatorHeight: LayoutMetric
    var separatorBottomPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Button.Ghost.focusBackground)
        ]
        self.contentViewRadius = 12
        
        self.title = [
            .textColor(Colors.Text.main),
            .font(Typography.bodyLargeMedium())
        ]
        self.titleHorizontalPadding = 12
        
        self.iconHorizontalPadding = 16
        self.iconVerticalPadding = 18
        
        self.description = [
            .textColor(Colors.Text.sonicSilver),
            .font(Typography.footnoteRegular()),
            .text(String(localized: "title-recently-used-card"))
        ]
        self.spaceBetweenTitleAndDescription = 20
        
        self.image = [
            .image("menu-card-banner-image"),
            .contentMode(.scaleAspectFit)
        ]
        self.imageVerticalPadding = 25
        
        self.cardView = [
            .image("menu-card-enabled-banner-image")
        ]
        self.cardViewPaddings = (16, 16, 20, 16)
        self.cardNumber = [
            .textColor(Colors.Text.main),
            .font(Typography.bodyRegular())
        ]
        self.cardBalance = [
            .textColor(Colors.Text.sonicSilver),
            .font(Typography.footnoteRegular())
        ]
        
        self.arrow = [
            .image("icon-arrow-24")
        ]
        
        self.action = [
            .titleColor([ .normal(Colors.Helpers.positive)]),
            .font(Typography.bodyMedium()),
            .title(String(localized: "title-view-cards"))
        ]
        self.actionHeight = 56
        
        self.separatorHeight = 1
        self.separatorBottomPadding = 56
    }
}
