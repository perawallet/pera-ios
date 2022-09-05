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

//   SwapAssetAmountViewTheme.swift

import MacaroonUIKit
import UIKit

struct SwapAssetAmountViewTheme:
    StyleSheet,
    LayoutSheet {
    let leftTitle: TextStyle
    let spacingBetweenLeftTitleAndAmountInput: LayoutMetric
    let rightTitle: TextStyle
    let spacingBetweenRightTitleAndAssetSelection: LayoutMetric
    let minimumSpacingBetweenTitles: LayoutMetric
    let assetAmountInput: AssetAmountInputViewTheme
    let assetSelection: SwapAssetSelectionViewTheme
    let minimumSpacingBetweenInputAndSelection: LayoutMetric
    
    init(
        placeholder: String,
        family: LayoutFamily = .current
    ) {
        self.leftTitle = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineFittingText()),
            .textAlignment(.right)
        ]
        self.spacingBetweenLeftTitleAndAmountInput = 12
        self.rightTitle = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineFittingText()),
            .textAlignment(.right)
        ]
        self.spacingBetweenRightTitleAndAssetSelection = 12
        self.minimumSpacingBetweenTitles = 4
        self.assetAmountInput = AssetAmountInputViewTheme(
            placeholder: placeholder,
            family: family
        )
        self.assetSelection = SwapAssetSelectionViewTheme()
        self.minimumSpacingBetweenInputAndSelection = 4
    }

    init(
        _ family: LayoutFamily
    ) {
        self.init(
            placeholder: .empty,
            family: family
        )
    }
}
