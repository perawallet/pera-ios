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

//   SendCollectibleAccountListViewControllerTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SendCollectibleAccountListViewControllerTheme:
    StyleSheet,
    LayoutSheet {
    let background: ViewStyle
    let horizontalPadding: LayoutMetric
    let searchInputViewTopPadding: LayoutMetric
    let clipboardPaddings: LayoutPaddings
    let contentInsetTopForClipboard: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        background = [
            .backgroundColor(AppColors.Shared.System.background)
        ]
        horizontalPadding = 24
        searchInputViewTopPadding = 16
        clipboardPaddings = (20, 0, 0, 0)
        contentInsetTopForClipboard = 112
    }
}
