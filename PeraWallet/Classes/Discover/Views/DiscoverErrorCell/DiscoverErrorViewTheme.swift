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

//   DiscoverErrorViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct DiscoverErrorViewTheme:
    StyleSheet,
    LayoutSheet {
    var contentVerticalEdgeInsets: LayoutVerticalPaddings
    var icon: ImageStyle
    var iconSize: CGSize
    var iconCorner: Corner
    var spacingBetweenIconAndTitle: CGFloat
    var title: TextStyle
    var spacingBetweenTitleAndBody: CGFloat
    var body: TextStyle
    var spacingBetweenBodyAndRetryAction: CGFloat
    var retryAction: ButtonStyle
    var retryActionContentEdgeInsets: UIEdgeInsets
    var retryActionMinSize: CGSize

    init(_ family: LayoutFamily) {
        self.contentVerticalEdgeInsets = (8, 8)
        self.icon = [
            .backgroundColor(Colors.Helpers.negative.uiColor.withAlphaComponent(0.1)),
            .contentMode(.center),
            .tintColor(Colors.Helpers.negative)
        ]
        self.iconSize = .init(width: 48, height: 48)
        self.iconCorner = 16
        self.spacingBetweenIconAndTitle = 20
        self.title = [
            .textAlignment(.center),
            .textColor(Colors.Text.main),
            .textOverflow(FittingText())
        ]
        self.spacingBetweenTitleAndBody = 8
        self.body = [
            .textAlignment(.center),
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText())
        ]
        self.spacingBetweenBodyAndRetryAction = 20
        self.retryAction = [
            .backgroundImage([
                .normal("primary-btn-bg"),
                .highlighted("primary-btn-bg-highlighted")
            ]),
            .font(Typography.footnoteMedium()),
            .title(String(localized: "title-try-again")),
            .titleColor([
                .normal(Colors.Button.Primary.newText)
            ])
        ]
        self.retryActionContentEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)
        self.retryActionMinSize = .init(width: 128, height: 44)
    }
}
