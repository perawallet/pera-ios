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

//   ExportAccountsDomainConfirmationScreenTheme.swift

import Foundation
import MacaroonUIKit

struct ExportAccountsDomainConfirmationScreenTheme:
    LayoutSheet,
    StyleSheet {
    let background: ViewStyle
    let body: TextStyle
    let spacingBetweenBodyAndDomainInput: LayoutMetric
    let domainInput: FloatingTextInputFieldViewTheme
    let domainInputMinHeight: LayoutMetric
    let spacingBetweenDomainInputAndDisclaimerContent: LayoutMetric
    let disclaimerIcon: ImageStyle
    let disclaimerIconLayoutOffset: LayoutOffset
    let disclaimerIconCorner: Corner
    let spacingBetweenDislaimerIconAndDisclaimerTitle: LayoutMetric
    let disclaimerTitle: TextStyle
    let spacingBetweenDisclaimerBodyAndIcon: LayoutMetric
    let disclaimerBody: TextStyle
    let spacingBetweenDisclaimerBodyAndPeraWebURL: LayoutMetric
    let contextEdgeInsets: LayoutPaddings
    let peraWebURLContentFirstShadow: MacaroonUIKit.Shadow
    let peraWebURLContentSecondShadow: MacaroonUIKit.Shadow
    let peraWebURLContentThirdShadow: MacaroonUIKit.Shadow
    let peraWebURLContentMinHeight: LayoutMetric
    let peraWebURLContentEdgeInsets: LayoutPaddings
    let peraWebURLAccessoryIcon: ImageStyle
    let spacingBetweenPeraWebURLAccessoryAndPeraWebURL: LayoutMetric
    let peraWebURL: TextStyle
    let continueAction: ButtonStyle
    let continueActionEdgeInsets: LayoutPaddings
    let continueActionContentEdgeInsets: LayoutPaddings

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.contextEdgeInsets = (0, 24, 8, 24)
        self.body = [
            .text("web-export-accounts-domain-confirmation-body".localized.bodyRegular()),
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText())
        ]
        self.spacingBetweenBodyAndDomainInput = 40
        let textInputBaseStyle: TextInputStyle = [
            .font(Typography.bodyRegular()),
            .tintColor(Colors.Text.main),
            .textColor(Colors.Text.main),
            .clearButtonMode(.whileEditing),
            .returnKeyType(.done),
            .textContentType(.URL),
            .keyboardType(.URL)
        ]
        let domainInput =
            FloatingTextInputFieldViewCommonTheme(
                textInput: textInputBaseStyle,
                placeholder: "web-export-accounts-domain-confirmation-input-placeholder".localized,
                floatingPlaceholder: "web-export-accounts-domain-confirmation-input-floating-placeholder".localized
            )
        self.domainInput = domainInput
        self.domainInputMinHeight = 48
        self.spacingBetweenDomainInputAndDisclaimerContent = 32
        self.disclaimerIcon = [
            .image("badge-warning"),
            .contentMode(.center),
            .backgroundColor(Colors.Helpers.negativeLighter)
        ]
        self.disclaimerIconLayoutOffset = (12, 12)
        self.disclaimerIconCorner = 16
        self.spacingBetweenDislaimerIconAndDisclaimerTitle = 12
        self.disclaimerTitle = [
            .text("title-disclaimer".localized.footnoteHeadingMedium(lineBreakMode: .byTruncatingTail)),
            .textColor(Colors.Helpers.negative),
            .textOverflow(SingleLineText())
        ]
        self.spacingBetweenDisclaimerBodyAndIcon = 12
        self.disclaimerBody = [
            .text("web-export-accoounts-domain-confirmation-disclaimer-body".localized.footnoteRegular()),
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText())
        ]
        self.spacingBetweenDisclaimerBodyAndPeraWebURL = 10
        self.peraWebURLContentFirstShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow3.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            spread: 1,
            cornerRadii: (12, 12),
            corners: .allCorners
        )
        self.peraWebURLContentSecondShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow2.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: 0,
            cornerRadii: (12, 12),
            corners: .allCorners
        )
        self.peraWebURLContentThirdShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow1.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: -1,
            cornerRadii: (12, 12),
            corners: .allCorners
        )
        self.peraWebURLContentMinHeight = 44
        self.peraWebURLContentEdgeInsets = (12, 12, 12, 12)
        self.peraWebURLAccessoryIcon = [
            .image("icon-locked-16".templateImage),
            .tintColor(Colors.Helpers.positive)
        ]
        self.spacingBetweenPeraWebURLAccessoryAndPeraWebURL = 8
        self.peraWebURL = [
            .text(AlgorandWeb.peraWebApp.rawValue.footnoteMedium(lineBreakMode: .byTruncatingTail)),
            .textColor(Colors.Helpers.positive),
            .textOverflow(SingleLineText())
        ]
        self.continueAction = [
            .title("title-continue".localized),
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
        self.continueActionEdgeInsets = (16, 8, 16, 8)
        self.continueActionContentEdgeInsets = (8, 24, 12, 24)
    }
}
