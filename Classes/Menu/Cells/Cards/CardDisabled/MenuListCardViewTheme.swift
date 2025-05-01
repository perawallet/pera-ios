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
    var background: ViewStyle
    var contentViewRadius: LayoutMetric
    var title: TextStyle
    var titleHorizontalPadding: LayoutMetric
    var description: TextStyle
    var spaceBetweenTitleAndDescription: LayoutMetric
    var iconHorizontalPadding: LayoutMetric
    var iconVerticalPadding: LayoutMetric
    let image: ImageStyle
    let imageVerticalPadding: LayoutMetric
    let action: ButtonStyle
    let actionPadding: LayoutMetric
    let actionHeight: LayoutMetric
    let actionTitleEdgeInsets: UIEdgeInsets
    let actionImageEdgeInsets: UIEdgeInsets

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
            .font(Typography.bodyRegular())
        ]
        self.spaceBetweenTitleAndDescription = 24
        
        self.image = [
            .image("menu-card-banner-image"),
            .contentMode(.scaleAspectFit)
        ]
        self.imageVerticalPadding = 25
        
        self.action = [
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
        self.actionPadding = 16
        self.actionHeight = 52
        self.actionTitleEdgeInsets = .init(top: 0, left: 6, bottom: 0, right: -6)
        self.actionImageEdgeInsets = .init(top: 0, left: -6, bottom: 0, right: 6)
    }
}
