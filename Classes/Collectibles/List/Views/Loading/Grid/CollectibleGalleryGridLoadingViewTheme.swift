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

//   CollectibleGalleryGridLoadingViewTheme.swift

import MacaroonUIKit

struct CollectibleGalleryGridLoadingViewTheme:
    StyleSheet,
    LayoutSheet {
    let managementItemTheme: ManagementItemViewTheme
    let managementItemTopPadding: LayoutMetric

    let uiActions: CollectibleGalleryUIActionsViewTheme
    let uiActionsPaddings: LayoutPaddings
    let uiActionsHeight: LayoutMetric

    let collectibleListItemsVerticalStackSpacing: LayoutMetric
    let collectibleListItemsVerticalStackPaddings: LayoutPaddings

    let collectibleListItemsHorizontalStackSpacing: LayoutMetric

    let collectibleListItemLoadingViewTheme: CollectibleListItemLoadingViewTheme

    let corner: Corner

    init(
        _ family: LayoutFamily
    ) {
        managementItemTheme = ManagementItemViewTheme()
        managementItemTopPadding = 28

        uiActions = CollectibleGalleryUIActionsViewTheme(family)
        uiActionsPaddings = (16, 0, .noMetric, 0)
        uiActionsHeight = 40

        collectibleListItemsVerticalStackSpacing = 20
        collectibleListItemsVerticalStackPaddings = (28, 0, 8, 0)

        collectibleListItemsHorizontalStackSpacing = 24

        collectibleListItemLoadingViewTheme = CollectibleListItemLoadingViewTheme()

        corner = Corner(radius: 4)
    }
}
