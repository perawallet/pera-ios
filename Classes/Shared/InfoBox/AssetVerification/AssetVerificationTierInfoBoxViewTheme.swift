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

//   AssetVerificationTierInfoBoxViewTheme.swift

import MacaroonUIKit
import UIKit

struct AssetVerificationTierInfoBoxViewTheme: InfoBoxViewTheme {
    let icon: ImageStyle
    let title: TextStyle
    let message: TextStyle

    let contentPaddings: LayoutPaddings
    let iconContentEdgeInsets: LayoutOffset
    let spacingBetweenTitleAndMessage: LayoutMetric

    init(_ family: LayoutFamily) {
        icon = [
            .contentMode(.left)
        ]
        title = [
            .textOverflow(FittingText())
        ]
        message = [
            .textOverflow(FittingText())
        ]

        contentPaddings = (20, 20, 20, 24)
        iconContentEdgeInsets = (16, 0)
        spacingBetweenTitleAndMessage = 8
    }
}
