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

//   ApproveCollectibleTransactionInfoViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ApproveCollectibleTransactionInfoViewTheme:
    StyleSheet,
    LayoutSheet {
    let contextViewSpacing: LayoutMetric
    let title: TextStyle
    let titleMinimumWidthRatio: LayoutMetric
    let iconSize: LayoutSize
    let iconHorizontalPaddings: LayoutPaddings
    let value: TextStyle

    init(
        _ family: LayoutFamily
    ) {
        contextViewSpacing = 8
        iconSize = (24, 24)
        iconHorizontalPaddings = (0, 8, 0, 8)
        title = [
            .textOverflow(SingleLineText()),
            .textColor(AppColors.Components.Text.gray)
        ]
        titleMinimumWidthRatio = 0.25
        value = [
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.main)
        ]
    }
}
