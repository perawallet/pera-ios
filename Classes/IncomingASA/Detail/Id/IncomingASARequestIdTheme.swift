// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   IncomingAsaApprovalIdViewtheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct IncomingASARequestIdTheme:
    LayoutSheet,
    StyleSheet {
    let dividerLine: ViewStyle
    let dividerLineMinWidth: LayoutMetric
    let dividerLineHeight: LayoutMetric
    let spacingBetweenDividerTitleAndLine: LayoutMetric
    let action: ButtonStyle
    let id: TextStyle
    let idLeftInset: LayoutMetric
    let idSeperatorPadding: LayoutMetric
    let idSeperatorTopInset: LayoutMetric
    var primaryActionContentEdgeInsets: LayoutPaddings
    let copyActionRightInset: LayoutMetric
    let copyActionBottomInset: LayoutMetric
    let copyActionHeight: LayoutMetric
    let copyActionCorner: LayoutMetric

    init(_ family: LayoutFamily) {
        self.dividerLine = [ .backgroundColor(Colors.Layer.grayLighter) ]
        self.dividerLineMinWidth = 40
        self.dividerLineHeight = 1
        self.spacingBetweenDividerTitleAndLine = 16
        self.action = [
            .titleColor([ .normal(Colors.Text.main) ]),
            .font(Typography.footnoteMedium()),
            .backgroundImage([
                .normal("components/buttons/secondary/bg"),
                .highlighted("components/buttons/secondary/bg-highlighted"),
                .selected("components/buttons/secondary/bg-highlighted"),
                .disabled("components/buttons/secondary/bg-disabled")
            ]),
            .title(String(localized: "title-copy-id"))
        ]
        
        self.primaryActionContentEdgeInsets = (4, 20, 4, 20)

        self.id = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText()),
            .font(Typography.bodyRegular())
        ]
        self.idLeftInset = 20
        self.idSeperatorPadding = 20
        self.idSeperatorTopInset = 16
        self.copyActionRightInset = 20
        self.copyActionBottomInset = 53
        self.copyActionHeight = 32
        self.copyActionCorner = 15
    }
}
