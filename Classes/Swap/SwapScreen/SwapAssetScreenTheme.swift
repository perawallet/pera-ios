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

//   SwapAssetScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SwapAssetScreenTheme:
    StyleSheet,
    LayoutSheet {
    let background: ViewStyle
    let userAsset: SwapAssetAmountViewTheme
    let assetHorizontalInset: LayoutMetric
    let userAssetTopInset: LayoutMetric
    let emptyPoolAsset: SwapAssetSelectionEmptyViewTheme
    let poolAsset: SwapAssetAmountViewTheme
    let poolAssetTopInset: LayoutMetric
    let swapAction: ButtonStyle
    let swapActionContentEdgeInsets: UIEdgeInsets
    let swapActionEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.userAsset = SwapAssetAmountViewTheme(placeholder: "0.00")
        self.assetHorizontalInset = 24
        self.userAssetTopInset = 24
        self.emptyPoolAsset = SwapAssetSelectionEmptyViewTheme()
        self.poolAsset = SwapAssetAmountViewTheme(placeholder: "0.00")
        self.poolAssetTopInset = 32
        self.swapAction = [
            .title("title-swap".localized),
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
        self.swapActionContentEdgeInsets = .init(
            (
                top: 16,
                leading: 0,
                bottom: 16,
                trailing: 0
            )
        )
        self.swapActionEdgeInsets = (24, 24, 16, 24)
    }
}
