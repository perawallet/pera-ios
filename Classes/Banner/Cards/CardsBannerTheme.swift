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

//   CardsBannerTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct CardsBannerTheme:
    StyleSheet,
    LayoutSheet {
    let background: ViewStyle
    let corner: Corner
    let contentPaddings: LayoutPaddings
    let title: TextStyle
    let titleHeight: LayoutMetric
    let titleTrailingMargin: LayoutMetric
    let spacingBetweenTitleAndSubtitle: LayoutMetric
    let subtitle: TextStyle
    let subtitleHeight: LayoutMetric
    let subtitleTrailingMargin: LayoutMetric
    let spacingBetweenContextAndImage: LayoutMetric
    let image: ImageStyle
    let imageTopMargin: LayoutMetric
    let spacingBetweenSubtitleAndAction: LayoutMetric
    let action: ButtonStyle
    let actionCorner: Corner
    let actionEdgeInsets: LayoutPaddings
    let closeAction: ButtonStyle
    let closeActionWidth: LayoutMetric
    let closeActionPadding: LayoutMetric
    let closeActionCorner: Corner
    let closeActionEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Discover.main)
        ]
        self.corner = Corner(radius: 8)
        self.contentPaddings = (24, 24, 20, 24)
        self.title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.white)
        ]
        self.titleHeight = 28
        self.titleTrailingMargin = 42
        self.spacingBetweenTitleAndSubtitle = 12
        self.subtitle = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.white)
        ]
        self.subtitleHeight = 50
        self.subtitleTrailingMargin = 130
        self.spacingBetweenContextAndImage = 12
        self.image = [
            .contentMode(.scaleAspectFit)
        ]
        self.imageTopMargin = 8
        self.spacingBetweenSubtitleAndAction = 13
        self.action = [
            .titleColor([.normal(Colors.Text.white)]),
            .backgroundColor(Colors.Text.white.uiColor.withAlphaComponent(0.12)),
        ]
        self.actionCorner = Corner(radius: 4)
        self.actionEdgeInsets = (8, 16, 8, 16)
        self.closeAction = [
            .icon([.normal("icon-field-close".templateImage)]),
            .backgroundColor(Colors.Text.white.uiColor.withAlphaComponent(0.12)),
            .tintColor(Colors.Text.white)
        ]
        self.closeActionWidth = 24
        self.closeActionPadding = 10
        self.closeActionCorner = Corner(radius: closeActionWidth / 2)
        self.closeActionEdgeInsets = (8, 16, 8, 16)
    }
}
