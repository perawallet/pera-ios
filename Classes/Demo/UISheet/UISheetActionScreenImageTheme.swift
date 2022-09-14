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

//   UISheetActionScreenImageTheme.swift

import Foundation
import MacaroonUIKit

struct UISheetActionScreenImageTheme:
    UISheetActionScreenTheme {
    var contextEdgeInsets: LayoutPaddings
    var image: ImageStyle
    var imageLayoutOffset: LayoutOffset
    var title: TextStyle
    var spacingBetweenTitleAndBody: LayoutMetric
    var body: TextStyle
    var actionSpacing: LayoutMetric
    var actionsEdgeInsets: LayoutPaddings
    var actionContentEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        contextEdgeInsets = (32, 24, 24, 24)
        image = [
            .contentMode(.top)
        ]
        imageLayoutOffset = (0, 16)
        title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Typography.bodyLargeMedium())
        ]
        spacingBetweenTitleAndBody = 12
        body = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray),
            .font(Typography.bodyRegular())
        ]
        actionSpacing = 16
        actionsEdgeInsets = (8, 24, 16, 24)
        actionContentEdgeInsets = (16, 24, 16, 24)
    }
}
