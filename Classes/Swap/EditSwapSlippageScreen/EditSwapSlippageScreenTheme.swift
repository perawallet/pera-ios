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

//   EditSlippageToleranceScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct EditSwapSlippageScreenTheme:
    StyleSheet,
    LayoutSheet {
    var slippageTolerancePercentageInputEdgeInsets: NSDirectionalEdgeInsets
    var slippageTolerancePercentageInput: AdjustableSingleSelectionInputViewTheme

    init(_ family: LayoutFamily) {
        self.slippageTolerancePercentageInputEdgeInsets =
            .init(top: 40, leading: 0, bottom: 40, trailing: 0)

        self.slippageTolerancePercentageInput = .init(
            textInputPlaceholder: String(localized: "swap-slippage-placeholder"),
            family: family
        )
        self.slippageTolerancePercentageInput.contentEdgeInsets =
            .init(top: 0, leading: 24, bottom: 0, trailing: 24)
    }
}
