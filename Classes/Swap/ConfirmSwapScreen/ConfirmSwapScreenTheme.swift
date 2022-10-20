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

//   ConfirmSwapScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ConfirmSwapScreenTheme:
    StyleSheet,
    LayoutSheet {
    let background: ViewStyle
    let userAsset: SwapAssetAmountViewTheme
    let assetHorizontalInset: LayoutMetric
    let userAssetTopInset: LayoutMetric
    let toSeparator: TitleSeparatorViewTheme
    let toSeparatorTopInset: LayoutMetric
    let poolAsset: SwapAssetAmountViewTheme
    let poolAssetTopInset: LayoutMetric
    let assetSeparator: Separator
    let assetSeparatorPadding: LayoutMetric
    let infoActionItem: SwapInfoActionItemViewTheme
    let infoItem: SwapInfoItemViewTheme
    let infoSectionPaddings: LayoutPaddings
    let infoSectionItemSpacing: LayoutMetric
    let viewSummary: ButtonStyle
    let confirmAction: ButtonStyle
    let confirmActionContentEdgeInsets: UIEdgeInsets
    let confirmActionEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.userAsset = SwapAssetAmountViewTheme(placeholder: "0.00")
        self.assetHorizontalInset = 24
        self.userAssetTopInset = 96
        self.toSeparator = TitleSeparatorViewTheme()
        self.toSeparatorTopInset = 20
        self.poolAsset = SwapAssetAmountViewTheme(placeholder: "0.00")
        self.poolAssetTopInset = 20
        self.assetSeparator = Separator(
            color: Colors.Layer.grayLighter,
            size: 1
        )
        self.assetSeparatorPadding = 88
        self.infoSectionPaddings = (28, 24, .noMetric, 24)
        self.infoActionItem = SwapInfoActionItemViewTheme()
        self.infoItem = SwapInfoItemViewTheme()
        self.infoSectionItemSpacing = 16
        self.viewSummary = [
            .title("swap-confirm-view-summary-title".localized),
            .titleColor([
                .normal(Colors.Helpers.positive)
            ]),
            .font(Typography.footnoteMedium()),
        ]
        self.confirmAction = [
            .title("swap-confirm-title".localized),
            .titleColor(
                [
                    .normal(Colors.Button.Primary.text),
                    .disabled(Colors.Button.Primary.disabledText)
                ]
            ),
            .font(Typography.bodyMedium()),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
                .disabled("components/buttons/primary/bg-disabled")
            ])
        ]
        self.confirmActionContentEdgeInsets = .init(
            (
                top: 16,
                leading: 0,
                bottom: 16,
                trailing: 0
            )
        )
        self.confirmActionEdgeInsets = (28, 24, 16, 24)
    }
}
