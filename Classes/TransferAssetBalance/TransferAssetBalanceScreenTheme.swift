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

//   TransferAssetBalanceScreenTheme.swift

import Foundation
import MacaroonUIKit

struct TransferAssetBalanceScreenTheme:
    StyleSheet,
    LayoutSheet {
    var contentEdgeInsets: LayoutPaddings
    var separator: Separator
    var spacingBetweenSecondaryListItemAndSeparator: LayoutMetric
    var assetIDView: SecondaryListItemViewTheme
    var accountView: SecondaryListItemViewTheme
    var descriptionTopPadding: LayoutMetric
    var description: TextStyle
    var approveActionView: ButtonStyle
    var closeActionView: ButtonStyle
    var spacingBetweenActions: LayoutMetric
    var actionContentEdgeInsets: LayoutPaddings
    let actionCorner: Corner
    var actionsContentEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        contentEdgeInsets = (36, 24, 32, 24)
        separator = Separator(
            color: Colors.Layer.grayLighter,
            size: 1,
            position: .bottom((contentEdgeInsets.leading, contentEdgeInsets.trailing))
        )
        spacingBetweenSecondaryListItemAndSeparator = 10
        assetIDView = AssetIDSecondaryListItemViewTheme()
        accountView = SecondaryListItemCommonViewTheme()
        descriptionTopPadding = 22
        description = [
            .textOverflow(FittingText())
        ]
        approveActionView = [
            .titleColor([ .normal(Colors.Button.Primary.text) ]),
            .backgroundColor(Colors.Button.Primary.background),
        ]
        closeActionView = [
            .titleColor([ .normal(Colors.Button.Secondary.text) ]),
            .backgroundColor(Colors.Button.Secondary.background)
        ]
        spacingBetweenActions = 16
        actionContentEdgeInsets = (14, 0, 14, 0)
        actionCorner = Corner(radius: 4)
        actionsContentEdgeInsets = (16, 24, 16, 24)
    }
}
