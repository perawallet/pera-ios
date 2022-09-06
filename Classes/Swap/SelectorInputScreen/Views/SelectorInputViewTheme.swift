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

//   SelectorInputViewTheme.swift

import Foundation
import MacaroonUIKit

struct SelectorInputViewTheme:
    StyleSheet,
    LayoutSheet {
    let horizontalPadding: LayoutMetric

    let textInput: FloatingTextInputFieldViewTheme
    let textInputHeight: LayoutMetric
    let textInputTopPadding: LayoutMetric

    let selectorOptionsSpacing: LayoutMetric
    let selectorOptionsTopPadding: LayoutMetric
    let selectorOptionsTrailingPadding: LayoutMetric
    let selectorOptionsBottomPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.horizontalPadding = 24

        let textInputBaseStyle: TextInputStyle = [
            .font(Typography.bodyRegular()),
            .tintColor(Colors.Text.main),
            .textColor(Colors.Text.main)
        ]
        self.textInput = FloatingTextInputFieldViewCommonTheme(
            textInput: textInputBaseStyle,
            placeholder: "swap-slippage-placeholder".localized
        )
        self.textInputHeight = 48
        self.textInputTopPadding = 32

        self.selectorOptionsSpacing = 12
        self.selectorOptionsTopPadding = 28
        self.selectorOptionsTrailingPadding = 77
        self.selectorOptionsBottomPadding = 40
    }
}
