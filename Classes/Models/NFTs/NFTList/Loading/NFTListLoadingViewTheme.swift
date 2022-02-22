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

//   NFTListLoadingViewTheme.swift

import MacaroonUIKit

struct NFTListLoadingViewTheme:
    StyleSheet,
    LayoutSheet {
    let searchInputPaddings: LayoutPaddings
    let searchInputHeight: LayoutMetric

    let nftListItemsVerticalStackSpacing: LayoutMetric
    let nftListItemsVerticalStackPaddings: LayoutPaddings

    let nftListItemsHorizontalStackSpacing: LayoutMetric

    let corner: Corner

    init(
        _ family: LayoutFamily
    ) {
        searchInputPaddings = (20, 24, .noMetric, 24)
        searchInputHeight = 40

        nftListItemsVerticalStackSpacing = 28
        nftListItemsVerticalStackPaddings = (24, 24, .noMetric, 24)

        nftListItemsHorizontalStackSpacing = 24.5

        corner = Corner(radius: 4)
    }
}
