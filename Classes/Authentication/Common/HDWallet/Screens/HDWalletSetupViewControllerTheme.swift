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

//
//   HDWalletSetupViewControllerTheme.swift

import MacaroonUIKit

struct HDWalletSetupViewControllerTheme:
    LayoutSheet,
    StyleSheet {
    let background: ViewStyle
    let contentEdgeInsets: LayoutPaddings
    let title: TextStyle
    let spacingBetweenTitleAndDescription: LayoutMetric
    let description: TextStyle
    let spacingListView: LayoutMetric
    let action: ButtonStyle
    let actionSpacingBetweenIconAndTitle: LayoutMetric
    let actionEdgeInsets: LayoutPaddings
    let actionContentEdgeInsets: LayoutPaddings

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.contentEdgeInsets = (2, 24, 0, 24)
        self.title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .text("hd-wallet-setup-title".localized.titleMedium(lineBreakMode: .byTruncatingTail))
        ]
        self.spacingBetweenTitleAndDescription = 16
        self.description = [
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText()),
            .text("hd-wallet-setup-description".localized.bodyRegular(lineBreakMode: .byTruncatingTail))
        ]
        self.spacingListView = 28
        self.action = [
            .font(Typography.bodyMedium()),
            .titleColor([
                .normal(Colors.Button.Secondary.text),
                .disabled(Colors.Button.Secondary.disabledText)
            ]),
            .backgroundImage([
                .normal("components/buttons/secondary/bg"),
                .highlighted("components/buttons/secondary/bg-highlighted"),
                .disabled("components/buttons/secondary/bg-disabled")
            ])
        ]
        self.actionSpacingBetweenIconAndTitle = 12
        self.actionEdgeInsets = (16, 8, 16, 16)
        self.actionContentEdgeInsets = (8, 24, 12, 24)
    }
}

struct HDWalletListItemViewTheme: StyleSheet, LayoutSheet {
    var icon: ImageStyle
    var iconSize: LayoutSize
    var iconViewSize: LayoutSize
    var iconViewCornerRadius: LayoutMetric
    var titleTheme: HDWalletListItemTitleViewTheme
    var currencyTheme: HDWalletListItemCurrencyViewTheme

    init(_ family: LayoutFamily) {
        self.icon = [
            .image("icon-add-account"),
            .contentMode(.scaleAspectFit),
        ]
        self.iconSize = (24, 24)
        self.iconViewSize = (40, 40)
        self.iconViewCornerRadius = self.iconViewSize.h / 2
        self.titleTheme = HDWalletListItemTitleViewTheme(family)
        self.currencyTheme = HDWalletListItemCurrencyViewTheme(family)
    }
}

struct HDWalletListItemTitleViewTheme: StyleSheet, LayoutSheet {
    var title: TextStyle
    var subtitle: TextStyle
    let spacing: LayoutMetric

    init(_ family: LayoutFamily) {
        self.title = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main),
            .font(Typography.bodyRegular())
        ]
        self.subtitle = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.grayLighter),
            .font(Typography.footnoteRegular())
        ]
        self.spacing = 16
    }
}

struct HDWalletListItemCurrencyViewTheme: StyleSheet, LayoutSheet {
    var main: TextStyle
    var secondary: TextStyle
    let spacing: LayoutMetric

    init(_ family: LayoutFamily) {
        self.main = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main),
            .font(Typography.bodyMedium())
        ]
        self.secondary = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.sonicSilver),
            .font(Typography.footnoteRegular())
        ]
        self.spacing = 16
    }
}
