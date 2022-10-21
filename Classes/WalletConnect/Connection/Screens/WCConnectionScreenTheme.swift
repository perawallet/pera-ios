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

//   WCConnectionScreenTheme.swift

import UIKit
import MacaroonUIKit

struct WCConnectionScreenTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    
    let contextView: WCConnectionViewTheme
    
    let actionsHorizontalPadding: LayoutMetric
    let actionsVerticalPadding: LayoutMetric
    let actionContentEdgeInsets: LayoutPaddings
    let actionsStackViewSpacing: LayoutMetric
    let cancelAction: ButtonStyle
    let connectAction: ButtonStyle
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        
        self.contextView = WCConnectionViewTheme()
        
        self.actionsStackViewSpacing = 23
        self.actionsHorizontalPadding = 24
        self.actionsVerticalPadding = 12
        self.actionContentEdgeInsets = (14, 8, 14, 8)
        self.cancelAction = [
            .title("title-cancel".localized),
            .font(Typography.bodyMedium()),
            .titleColor([
                .normal(Colors.Button.Secondary.text),
                .disabled(Colors.Button.Secondary.disabledText)
            ]),
            .backgroundImage([
                .normal("components/buttons/secondary/bg"),
                .highlighted("components/buttons/secondary/bg-highlighted"),
                .disabled("components/buttons/secondary/bg-disabled")
            ])
        ]
        self.connectAction = [
            .title("title-connect".localized),
            .font(Typography.bodyMedium()),
            .titleColor([
                .normal(Colors.Button.Primary.text),
                .disabled(Colors.Button.Primary.disabledText)
            ]),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
                .disabled("components/buttons/primary/bg-disabled")
            ])
        ]
    }
}
