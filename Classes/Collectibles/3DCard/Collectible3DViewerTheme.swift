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

//   Collectible3DViewerTheme.swift

import MacaroonUIKit

struct Collectible3DViewerTheme:
    StyleSheet,
    LayoutSheet {
    let close: ButtonStyle

    let butonSize: LayoutSize
    let buttonTopPadding: LayoutMetric
    let buttonLeadingPadding: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        close = [
            .icon([.normal("icon-close-background")])
        ]

        butonSize = (44, 44)
        buttonTopPadding = 12
        buttonLeadingPadding = 20
    }
}
