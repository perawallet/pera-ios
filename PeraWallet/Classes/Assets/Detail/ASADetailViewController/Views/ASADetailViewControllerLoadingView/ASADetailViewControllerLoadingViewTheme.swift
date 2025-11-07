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

//   ASADetailViewControllerLoadingViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ASADetailViewControllerLoadingViewTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    var profile: ViewStyle
    var profileTopEdgeInset: LayoutMetric
    var profileHorizontalEdgeInsets: NSDirectionalHorizontalEdgeInsets
    var iconSize: LayoutSize
    var iconCorner: Corner
    var spacingBetweenIconAndTitle: LayoutMetric
    var titleSize: LayoutSize
    var spacingBetweenIconAndPrimaryValue: LayoutMetric
    var primaryValueSize: LayoutSize
    var spacingBetweenPrimaryAndSecondaryValue: LayoutMetric
    var secondaryValueSize: LayoutSize
    var spacingBetweenProfileAndQuickActions: LayoutMetric
    var quickActions: ViewStyle
    var spacingBetweenQuickActions: LayoutMetric
    var sendActionIcon: Image
    var sendActionTitle: TextProvider
    var receiveActionIcon: Image
    var receiveActionTitle: TextProvider
    var quickActionWidth: LayoutMetric
    var spacingBetweenQuickActionIconAndTitle: LayoutMetric
    var spacingBetweenQuickActionsAndPageBar: LayoutMetric
    var pageBarStyle: PageBarStyleSheet
    var pageBarLayout: PageBarLayoutSheet
    var holdingsPageBarItem: PageBarButtonItem
    var holdings: TransactionHistoryLoadingViewTheme
    var holdingsContentEdgeInsets: NSDirectionalEdgeInsets
    var marketsPageBarItem: PageBarButtonItem
    var markets: ASAAboutLoadingViewTheme
    var corner: Corner

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.profile = [
            .backgroundColor(Colors.Helpers.heroBackground)
        ]
        self.profileTopEdgeInset = 30
        self.profileHorizontalEdgeInsets = .init(leading: 24, trailing: 24)
        self.iconSize = (40, 40)
        self.iconCorner = Corner(radius: iconSize.h / 2)
        self.spacingBetweenIconAndTitle = 8
        self.titleSize = (90, 20)
        self.spacingBetweenIconAndPrimaryValue = 20
        self.primaryValueSize = (210, 36)
        self.spacingBetweenPrimaryAndSecondaryValue = 8
        self.secondaryValueSize = (40, 20)
        self.spacingBetweenProfileAndQuickActions = 48
        self.quickActions = [
            .backgroundColor(Colors.Helpers.heroBackground)
        ]
        self.spacingBetweenQuickActions = 16
        self.sendActionIcon = "send-icon"
        self.receiveActionIcon = "receive-icon"

        var quickActionTitleAttributes = Typography.footnoteRegularAttributes(
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        quickActionTitleAttributes.insert(.textColor(Colors.Text.main))

        self.sendActionTitle = String(localized: "quick-actions-send-title")
            .attributed(quickActionTitleAttributes)
        self.receiveActionTitle = String(localized: "quick-actions-receive-title")
            .attributed(quickActionTitleAttributes)

        self.quickActionWidth = 64
        self.spacingBetweenQuickActionIconAndTitle = 12
        self.spacingBetweenQuickActionsAndPageBar = 36
        self.pageBarStyle = PageBarCommonStyleSheet()
        self.pageBarLayout = PageBarCommonLayoutSheet()
        self.holdingsPageBarItem = PrimaryPageBarButtonItem(title: String(localized: "title-holdings"))
        self.holdings = TransactionHistoryLoadingViewCommonTheme()
        self.holdingsContentEdgeInsets = .init(top: 36, leading: 24, bottom: 0, trailing: 24)
        self.marketsPageBarItem = PrimaryPageBarButtonItem(title: String(localized: "asset-detail-markets-title"))
        self.markets = ASAAboutLoadingViewTheme()
        self.corner = Corner(radius: 4)
    }
}
