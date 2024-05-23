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
    var primaryActionContentEdgeInsets: LayoutPaddings
    
    init(_ family: LayoutFamily) {
        self.dividerLine = [ .backgroundColor(Colors.Layer.grayLighter) ]
        self.dividerLineMinWidth = 40
        self.dividerLineHeight = 1
        self.spacingBetweenDividerTitleAndLine = 16
        self.action = [
            .titleColor([ .normal(Colors.Text.gray) ]),
            .font(Typography.bodyMedium()),
            .backgroundImage([
                .normal("components/buttons/secondary/bg"),
                .highlighted("components/buttons/secondary/bg-highlighted"),
                .selected("components/buttons/secondary/bg-highlighted"),
                .disabled("components/buttons/secondary/bg-disabled")
            ]),
            .title("title-copy".localized)
        ]
        
        self.primaryActionContentEdgeInsets = (4, 20, 4, 20)

        self.id = [
            .textColor(Colors.Text.main),
            .textOverflow(SingleLineText())
        ]
    }
}
