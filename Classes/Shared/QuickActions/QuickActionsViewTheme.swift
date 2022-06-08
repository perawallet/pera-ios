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
    var maxContentHorizontalInsets: LayoutHorizontalPaddings
    var spacingBetweenActions: LayoutMetric
    var buyAlgoAction: QuickActionViewTheme
    var sendAction: QuickActionViewTheme
    var receiveAction: QuickActionViewTheme
    var scanAction: QuickActionViewTheme

    init(
        _ family: LayoutFamily
    ) {
        self.maxContentHorizontalInsets = (12, 12)
        self.spacingBetweenActions = 5

        var buyAlgoAction = QuickActionViewTheme(family)
        buyAlgoAction.icon = "buy-algo-icon"
        buyAlgoAction.title = "quick-actions-buy-algo-title".localized
        self.buyAlgoAction = buyAlgoAction

        var sendAction = QuickActionViewTheme(family)
        sendAction.icon = "send-icon"
        sendAction.title = "quick-actions-send-title".localized
        self.sendAction = sendAction

        var receiveAction = QuickActionViewTheme(family)
        receiveAction.icon = "receive-icon"
        receiveAction.title = "quick-actions-receive-title".localized
        self.receiveAction = receiveAction

        var scanAction = QuickActionViewTheme(family)
        scanAction.icon = "scan-qr-icon"
        scanAction.title = "quick-actions-scan-qr-title".localized
        self.scanAction = scanAction
    }
}

struct QuickActionViewTheme:
    StyleSheet,
    LayoutSheet {
    var icon: Image? {
        didSet { style.icon = icon.unwrap { [ .normal($0) ] } }
    }
    var title: String? {
        didSet { style.title = title }
    }

    private(set) var style: ButtonStyle

    let width: CGFloat

    static let spacingBetweenIconAndTitle: CGFloat = 15

    init(
        _ family: LayoutFamily
    ) {
        self.width = 64
        self.style = [
            .font(Fonts.DMSans.regular.make(13)),
            .titleColor([ .normal(AppColors.Components.Text.main) ])
        ]
    }
}
