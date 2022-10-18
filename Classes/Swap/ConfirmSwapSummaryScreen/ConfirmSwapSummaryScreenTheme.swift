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

//   ConfirmSwapSummaryScreenTheme.swift

import MacaroonUIKit
import UIKit

struct ConfirmSwapSummaryScreenTheme:
    StyleSheet,
    LayoutSheet {
    let accountInfo: SecondaryListItemViewTheme
    let accountInfoTopInset: LayoutMetric
    let accountSeparatorSpacing: LayoutMetric
    let horizontalInset: LayoutMetric
    let separator: Separator
    let spacingBetweenSeparatorAndInfo: LayoutMetric
    let infoItem: SwapInfoItemViewTheme
    let infoActionItem: SwapInfoActionItemViewTheme
    let itemVerticalInset: LayoutMetric
    let totalSwapFeeDetail: TextStyle
    let totalSwapFeeTopInset: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        self.accountInfo = SecondaryListItemCommonViewTheme()
        self.accountInfoTopInset = 18
        self.accountSeparatorSpacing = 18
        self.horizontalInset = 24
        self.separator = Separator(
            color: Colors.Layer.grayLighter,
            size: 1
        )
        self.spacingBetweenSeparatorAndInfo = 28
        self.infoItem = SwapInfoItemViewTheme()
        self.infoActionItem = SwapInfoActionItemViewTheme()
        self.itemVerticalInset = 16
        self.totalSwapFeeDetail = [
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray),
            .font(Typography.footnoteRegular()),
            .text("swap-confirm-total-fee-detail".localized)
        ]
        self.totalSwapFeeTopInset = 12
    }
}
