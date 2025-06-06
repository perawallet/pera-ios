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

//   MenuListCardViewTheme.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import UIKit

struct MenuListCardViewTheme:
    StyleSheet,
    LayoutSheet {
    let background: ViewStyle
    let contentViewRadius: LayoutMetric
    let title: TextStyle
    let titleHorizontalPadding: LayoutMetric
    let description: TextStyle
    let spaceBetweenTitleAndDescription: LayoutMetric
    let notSupportedCountryTitle: TextStyle
    let notSupportedCountryText: TextStyle
    let notSupportedCountryTextPadding: LayoutMetric
    let iconHorizontalPadding: LayoutMetric
    let iconVerticalPadding: LayoutMetric
    let image: ImageStyle
    let imageVerticalPadding: LayoutMetric
    let actionInactive: ButtonStyle
    let actionInactiveTitleEdgeInsets: UIEdgeInsets
    let actionInactiveImageEdgeInsets: UIEdgeInsets
    let actionActive: ButtonStyle
    let actionActiveTitleEdgeInsets: UIEdgeInsets
    let actionActiveImageEdgeInsets: UIEdgeInsets
    let actionPadding: LayoutMetric
    let actionHeight: LayoutMetric

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
            .font(Typography.bodyRegular()),
            .text(String(localized: "menu-card-banner-description"))
        ]
        self.spaceBetweenTitleAndDescription = 24
        
        self.notSupportedCountryTitle = [
            .textColor(Colors.Text.main),
            .font(Typography.bodyMedium()),
            .text(String(localized: "title-all-set"))
        ]
        self.notSupportedCountryText = [
            .textColor(Colors.Text.gray),
            .font(Typography.bodyRegular()),
            .text(String(localized: "cards-not-supported-country-text"))
        ]
        self.notSupportedCountryTextPadding = 126
        
        self.image = [
            .image("menu-card-banner-image"),
            .contentMode(.scaleAspectFit)
        ]
        self.imageVerticalPadding = 25
        
        self.actionInactive = [
            .titleColor([ .normal(Colors.Button.Primary.text), .disabled(Colors.Button.Primary.disabledText) ]),
            .icon([.normal("icon-plus")]),
            .font(Typography.bodyMedium()),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
                .selected("components/buttons/primary/bg-highlighted"),
                .disabled("components/buttons/primary/bg-disabled")
            ]),
            .title(String(localized: "title-create-pera-card"))
        ]
        self.actionInactiveTitleEdgeInsets = .init(top: 0, left: 6, bottom: 0, right: -6)
        self.actionInactiveImageEdgeInsets = .init(top: 0, left: -6, bottom: 0, right: 6)
        
        self.actionActive = [
            .titleColor([ .normal(Colors.Button.Primary.text), .disabled(Colors.Button.Primary.disabledText) ]),
            .icon([.normal("icon-list-arrow".templateImage)]),
            .font(Typography.bodyMedium()),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
                .selected("components/buttons/primary/bg-highlighted"),
                .disabled("components/buttons/primary/bg-disabled")
            ]),
            .title(String(localized: "title-go-to-cards")),
            .tintColor(Colors.Button.Primary.text)
        ]
        self.actionActiveTitleEdgeInsets = .init(top: 0, left: -6, bottom: 0, right: 6)
        self.actionActiveImageEdgeInsets = .init(top: 0, left: 6, bottom: 0, right: -6)
        
        self.actionPadding = 16
        self.actionHeight = 52

    }
}
