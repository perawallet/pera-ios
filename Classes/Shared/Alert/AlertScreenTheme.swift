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

//   AlertScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

protocol AlertScreenTheme:
    StyleSheet,
    LayoutSheet {
    var contextEdgeInsets: LayoutPaddings { get }
    var image: ImageStyle { get }
    var imageBottomPadding: LayoutMetric { get }
    var title: TextStyle { get }
    var spacingBetweenTitleAndBody: LayoutMetric { get }
    var body: TextStyle { get }
    var actionSpacing: LayoutMetric { get }
    var actionsEdgeInsets: LayoutPaddings { get }
    var actionContentEdgeInsets: LayoutPaddings { get }

    func getActionStyle(
        _ style: AlertAction.Style,
        title: String
    ) -> ButtonStyle
}

struct AlertScreenThemeCommonTheme:
    AlertScreenTheme {
    var contextEdgeInsets: LayoutPaddings
    var image: ImageStyle
    var imageBottomPadding: LayoutMetric
    var title: TextStyle
    var spacingBetweenTitleAndBody: LayoutMetric
    var body: TextStyle
    var actionSpacing: LayoutMetric
    var actionsEdgeInsets: LayoutPaddings
    var actionContentEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        self.contextEdgeInsets = (32, 24, 12, 24)
        self.image = [
            .contentMode(.top)
        ]
        self.imageBottomPadding = 32
        self.title = [
            .textOverflow(MultilineText(numberOfLines: 4)),
            .textColor(Colors.Text.main),
            .font(Typography.bodyLargeMedium())
        ]
        self.body = [
            .textOverflow(MultilineText(numberOfLines: 5)),
            .textColor(Colors.Text.gray),
            .font(Typography.footnoteRegular())
        ]
        self.spacingBetweenTitleAndBody = 12
        self.actionSpacing = 20
        self.actionContentEdgeInsets = (16, 24, 16, 24)
        self.actionsEdgeInsets = (8, 24, 32, 24)
    }

    func getActionStyle(
        _ style: AlertAction.Style,
        title: String
    ) -> ButtonStyle {
        switch style {
        case .primary:
            return .getPrimaryStyle(
                title: title
            )
        case .secondary:
            return .getSecondaryStyle(
                title: title
            )
        }
    }
}

fileprivate extension ButtonStyle {
    static func getPrimaryStyle(
        title: String
    ) -> ButtonStyle {
        return [
            .title(title),
            .font(Typography.bodyMedium()),
            .titleColor([ .normal(Colors.Button.Primary.text) ]),
            .backgroundImage([
                .normal("components/buttons/secondary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
            ])
        ]
    }

    static func getSecondaryStyle(
        title: String
    ) -> ButtonStyle {
        return  [
            .title(title),
            .font(Typography.bodyMedium()),
            .titleColor([ .normal(Colors.Button.Secondary.text) ]),
            .backgroundImage([
                .normal("components/buttons/secondary/bg"),
                .highlighted("components/buttons/secondary/bg-highlighted"),
            ])
        ]
    }
}
