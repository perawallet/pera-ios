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

//   SwapQuickActionsViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SwapQuickActionsViewTheme: StyleSheet, LayoutSheet {
    let backgroundImage: UIImage
    let horizontalSeparator: Separator
    let horizontalPadding: LayoutMetric
    let verticalSeparatorImage: UIImage

    init(_ family: LayoutFamily) {
        self.backgroundImage = "swap-divider-segment-bg".uiImage
        self.horizontalSeparator = Separator(
            color: Colors.Layer.grayLighter,
            size: 1,
            position: .centerY((0, 0))
        )
        self.horizontalPadding = 24
        self.verticalSeparatorImage = "swap-divider-separator".uiImage
    }
}
