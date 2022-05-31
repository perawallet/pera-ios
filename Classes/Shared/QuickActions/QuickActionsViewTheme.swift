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

//   QuickActionsViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct QuickActionsViewTheme:
    StyleSheet,
    LayoutSheet {
    var contentSafeAreaInsets: UIEdgeInsets
    var spacingBetweenActions: LayoutMetric
    var sendAction: ButtonStyle
    var receiveAction: ButtonStyle
    var buyAlgoAction: ButtonStyle
    var qrAction: ButtonStyle

    init(
        _ family: LayoutFamily
    ) {
        let actionFont = Fonts.DMSans.medium.make(15)
        let actionTitleColor = AppColors.Components.Text.main

        self.contentSafeAreaInsets = .zero
        self.spacingBetweenActions = 32
        self.buyAlgoAction = [
            .font(actionFont),
            .icon([ .normal("buy-algo-icon") ]),
            .title("quick-actions-buy-algo-title".localized),
            .titleColor([ .normal(actionTitleColor) ]),
        ]
        self.sendAction = [
            .font(actionFont),
            .icon([ .normal("send-icon") ]),
            .title("quick-actions-send-title".localized),
            .titleColor([ .normal(actionTitleColor) ])
        ]
        self.receiveAction = [
            .font(actionFont),
            .icon([ .normal("receive-icon") ]),
            .title("quick-actions-receive-title".localized),
            .titleColor([ .normal(actionTitleColor) ])
        ]
        self.qrAction = [
            .font(actionFont),
            .icon([ .normal("scan-qr-icon") ]),
            .title("quick-actions-scan-qr-title".localized),
            .titleColor([ .normal(actionTitleColor) ])
        ]
    }
}
