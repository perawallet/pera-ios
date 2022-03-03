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

//   ReceiveCollectibleAccountListViewControllerTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ReceiveCollectibleAccountListViewControllerTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    let title: TextStyle
    let titlePaddings: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        background = [
            .backgroundColor(AppColors.Shared.System.background)
        ]
        title = [
            .text(Self.getTitle()),
            .textColor(AppColors.Components.Text.main),
            .textOverflow(FittingText())
        ]
        titlePaddings = (12, 24, .noMetric, 24)
    }
}

extension ReceiveCollectibleAccountListViewControllerTheme {
    private static func getTitle() -> EditText {
        let font = Fonts.DMSans.medium.make(32)
        let lineHeightMultiplier = 0.96

        return .attributedString(
            "collectibles-receive-action"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
        )
    }
}
