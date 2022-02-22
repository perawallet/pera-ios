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

//   NFTListItemLoadingViewTheme.swift

import MacaroonUIKit

struct NFTListItemLoadingViewTheme:
    LayoutSheet,
    StyleSheet {
    let imageViewHeight: LayoutMetric

    let titleViewHeight: LayoutMetric
    let titleMargin: LayoutMargins
    let titleWidthMultiplier: LayoutMetric

    let subtitleViewHeight: LayoutMetric
    let subtitleMargin: LayoutMargins
    let subtitleWidthMultiplier: LayoutMetric

    let corner: Corner

    init(
        _ family: LayoutFamily
    ) {
        imageViewHeight = 151

        titleMargin = (12, .noMetric, .noMetric, 107)
        titleViewHeight = 16
        titleWidthMultiplier = 0.29
        
        subtitleMargin = (8, 16, .noMetric, 37.5)
        subtitleViewHeight = 20
        subtitleWidthMultiplier = 0.75

        corner = Corner(radius:  4)
    }
}
