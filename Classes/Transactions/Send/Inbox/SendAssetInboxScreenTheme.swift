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

//   SendAssetInboxScreenTheme.swift

import Foundation
import MacaroonUIKit

struct SendAssetInboxScreenTheme:
    LayoutSheet,
    StyleSheet {
    let background: ViewStyle
    let context: ViewStyle
    let contextTopPadding: LayoutMetric
    let title: TextStyle
    let titleTopPadding: LayoutMetric
    let titleHorizontalPadding: LayoutMetric
    let icon: ImageStyle
    let iconTopSpacing: LayoutMetric
    let spacingBetweenTitleAndIcon: LayoutMetric
    let subtitleTopPadding: LayoutMetric
    let subtitle: TextStyle
    let contentEdgeInsets: LayoutPaddings
    let separator: Separator
    let spacingBetweenSecondaryListItemAndSeparator: LayoutMetric
    let amountInformationView: SecondaryListItemViewTheme
    let feeInformationView: SecondaryListItemViewTheme
    let descriptionTopPadding: LayoutMetric
    let description: TextStyle
    let sendActionView: ButtonStyle
    let closeActionView: ButtonStyle
    let spacingBetweenActions: LayoutMetric
    let actionContentEdgeInsets: LayoutPaddings
    let actionsContentEdgeInsets: LayoutPaddings
    let closeActionBottomPadding: LayoutMetric
    
    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Helpers.heroBackground)
        ]
        self.context = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
        ]
        self.titleTopPadding = 32
        self.titleHorizontalPadding = 40
        self.icon = [
            .image("img-inbox-send")
        ]
        self.spacingBetweenTitleAndIcon = 28
        self.iconTopSpacing = 12
        self.subtitleTopPadding = 36
        self.contextTopPadding = 48
        self.subtitle = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
        ]
        self.contentEdgeInsets = (36, 24, 0, 24)
        self.separator = Separator(
            color: Colors.Layer.grayLighter,
            size: 1,
            position: .bottom((contentEdgeInsets.leading, contentEdgeInsets.trailing))
        )
        self.spacingBetweenSecondaryListItemAndSeparator = 12
        self.amountInformationView = SecondaryListItemCommonViewTheme()
        self.feeInformationView = FeeInformationSecondaryListItemViewTheme()
        self.descriptionTopPadding = 22
        self.description = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
        ]
        self.sendActionView = [
            .title(String(localized: "send-inbox-action-title")),
            .titleColor([ .normal(Colors.Button.Primary.text) ]),
            .font(Typography.bodyMedium()),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
            ])
        ]
        self.closeActionView = [
            .title(String(localized: "title-close")),
            .titleColor([ .normal(Colors.Button.Secondary.text) ]),
            .font(Typography.bodyMedium()),
            .backgroundImage([
                .normal("components/buttons/secondary/bg"),
                .highlighted("components/buttons/secondary/bg-highlighted"),
            ])
        ]
        self.spacingBetweenActions = 16
        self.actionContentEdgeInsets = (16, 24, 16, 24)
        self.actionsContentEdgeInsets = (32, 24, 16, 24)
        self.closeActionBottomPadding = 32
    }
}

private struct FeeInformationSecondaryListItemViewTheme: SecondaryListItemViewTheme {
    var contentEdgeInsets: LayoutPaddings
    var title: TextStyle
    var titleMinWidthRatio: LayoutMetric
    var titleMaxWidthRatio: LayoutMetric
    var minimumSpacingBetweenTitleAndAccessory: LayoutMetric
    var accessory: SecondaryListItemValueViewTheme

    init(
        _ family: LayoutFamily
    ) {
        contentEdgeInsets = (10, 24, 10, 24)
        title = [ .textOverflow(FittingText()) ]
        titleMinWidthRatio = 0.2
        titleMaxWidthRatio = 0.7
        minimumSpacingBetweenTitleAndAccessory = 12
        accessory = SecondaryListItemValueCommonViewTheme(family)
    }
}
