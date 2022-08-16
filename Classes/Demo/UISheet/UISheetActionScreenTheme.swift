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

//   UISheetActionScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

protocol UISheetActionScreenTheme:
    StyleSheet,
    LayoutSheet {
    var contextEdgeInsets: LayoutPaddings { get }
    var title: TextStyle { get }
    var spacingBetweenTitleAndBody: LayoutMetric { get }
    var body: TextStyle { get }
    var actionSpacing: LayoutMetric { get }
    var actionsEdgeInsets: LayoutPaddings { get }
    var actionCorner: Corner { get }
    var actionContentEdgeInsets: LayoutPaddings { get }

    func getActionStyle(
        _ style: UISheetAction.Style,
        title: String
    ) -> ButtonStyle
}

struct UISheetActionScreenCommonTheme:
    UISheetActionScreenTheme {
    var contextEdgeInsets: LayoutPaddings
    var title: TextStyle
    var spacingBetweenTitleAndBody: LayoutMetric
    var body: TextStyle
    var actionSpacing: LayoutMetric
    var actionsEdgeInsets: LayoutPaddings
    var actionCorner: Corner
    var actionContentEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        contextEdgeInsets = (36, 24, 32, 24)
        title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.medium.make(19))
        ]
        body = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.regular.make(15))
        ]
        spacingBetweenTitleAndBody = 16
        actionSpacing = 16
        actionContentEdgeInsets = (14, 24, 14, 24)
        actionCorner = Corner(radius: 4)
        actionsEdgeInsets = (.noMetric, 24, 16, 24)
    }

    func getActionStyle(
        _ style: UISheetAction.Style,
        title: String
    ) -> ButtonStyle {
        switch style {
        case .default:
            return .getDefaultStyle(
                title: title
            )
        case .cancel:
            return .getCancelStyle(
                title: title
            )
        }
    }
}

fileprivate extension ButtonStyle {
    static func getDefaultStyle(
        title: String
    ) -> ButtonStyle {
        return [
            .title(getTitle(title)),
            .titleColor([ .normal(Colors.Button.Primary.text) ]),
            .backgroundColor(Colors.Button.Primary.background),
        ]
    }

    static func getCancelStyle(
        title: String
    ) -> ButtonStyle {
        return  [
            .title(getTitle(title)),
            .titleColor([ .normal(Colors.Button.Secondary.text) ]),
            .backgroundColor(Colors.Button.Secondary.background)
        ]
    }

    private static func getTitle(
        _ aTitle: String
    ) -> EditText {
        .attributedString(
            aTitle.bodyMedium(
                lineBreakMode: .byTruncatingTail
            )
        )
    }
}
