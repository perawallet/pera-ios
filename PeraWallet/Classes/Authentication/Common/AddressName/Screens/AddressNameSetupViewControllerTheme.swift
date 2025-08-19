// Copyright 2022-2025 Pera Wallet, LDA

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
//   AddressNameSetupViewControllerTheme.swift

import MacaroonUIKit

struct AddressNameSetupViewControllerTheme:
    LayoutSheet,
    StyleSheet {
    let background: ViewStyle
    let contentEdgeInsets: LayoutPaddings
    let accountTitle: TextStyle
    let walletTitle: TextStyle
    let spacingBetweenTitleAndDescription: LayoutMetric
    let accountDescription: TextStyle
    let walletDescription: TextStyle
    let spacingBetweenDescriptionAndWalletName: LayoutMetric
    let walletNameViewCornerRadius: LayoutMetric
    let walletNameViewMinHeight: LayoutMetric
    let walletName: TextStyle
    let walletNameOffset: LayoutMetric
    let walletIcon: ImageStyle
    let walletIconHeight: LayoutMetric
    let spacingBetweenWalletNameAndNameInput: LayoutMetric
    let nameInput: FloatingTextInputFieldViewTheme
    let nameInputMinHeight: LayoutMetric
    let action: ButtonStyle
    let actionEdgeInsets: LayoutPaddings
    let actionContentEdgeInsets: LayoutPaddings

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.contentEdgeInsets = (2, 24, 0, 24)
        self.accountTitle = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .text(String(localized: "account-details-title").titleMedium(lineBreakMode: .byTruncatingTail))
        ]
        self.walletTitle = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .text(String(localized: "account-details-wallet-title").titleMedium(lineBreakMode: .byTruncatingTail))
        ]
        self.spacingBetweenTitleAndDescription = 16
        self.accountDescription = [
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText()),
            .text(String(localized: "account-name-setup-description").bodyRegular(lineBreakMode: .byTruncatingTail))
        ]
        self.walletDescription = [
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText()),
            .text(String(localized: "account-wallet-name-setup-description").bodyRegular(lineBreakMode: .byTruncatingTail))
        ]
        self.spacingBetweenDescriptionAndWalletName = 36
        self.walletNameViewCornerRadius = 8
        self.walletName = [
            .font(Typography.bodyRegular()),
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText()),
            .textAlignment(.center)
        ]
        self.walletNameOffset = 8
        self.walletIcon = [
            .image("icon-wallet-gray-18"),
            .contentMode(.scaleAspectFit)
        ]
        self.walletIconHeight = 18
        self.walletNameViewMinHeight = 32
        self.spacingBetweenWalletNameAndNameInput = 12
        let textInputBaseStyle: TextInputStyle = [
            .font(Typography.bodyRegular()),
            .tintColor(Colors.Text.main),
            .textColor(Colors.Text.main),
            .clearButtonMode(.whileEditing),
            .returnKeyType(.done),
            .autocapitalizationType(.words),
            .textContentType(.name)
        ]
        self.nameInput = FloatingTextInputFieldViewCommonTheme(
            textInput: textInputBaseStyle,
            placeholder: String(localized: "account-name-setup-placeholder"),
            floatingPlaceholder: String(localized: "account-name-setup-placeholder")
        )
        self.nameInputMinHeight = 48
        self.action = [
            .title(String(localized: "account-name-setup-finish")),
            .font(Typography.bodyMedium()),
            .titleColor([
                .normal(Colors.Button.Primary.text),
                .disabled(Colors.Button.Primary.disabledText)
            ]),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
                .disabled("components/buttons/primary/bg-disabled")
            ])
        ]
        self.actionEdgeInsets = (16, 8, 16, 8)
        self.actionContentEdgeInsets = (8, 24, 12, 24)
    }
}
