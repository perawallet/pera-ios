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

//   AccountQuickActionsView.swift

import MacaroonUIKit
import SnapKit
import UIKit

final class AccountQuickActionsView:
    View,
    ListReusable,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .swap: TargetActionInteraction(),
        .buy: TargetActionInteraction(),
        .requests: TargetActionInteraction(),
        .more: TargetActionInteraction()
    ]

    private lazy var contentView = HStackView()
    private let contentBackgroundView = UIView()
    private lazy var swapActionView = makeBadgeActionView()
    private lazy var buyActionView =  makeActionView()
    private lazy var requestsActionView = makeActionView()
    private lazy var moreActionView = makeActionView()

    private var theme: AccountQuickActionsViewTheme!

    var isSwapBadgeVisible: Bool = false {
        didSet {
            swapActionView.isBadgeVisible = isSwapBadgeVisible
        }
    }

    var isRequestsBadgeVisible: Bool = false {
        didSet {
            requestsActionView.customizeAppearance(isRequestsBadgeVisible ? theme.requestsBadgeAction : theme.requestsAction)
        }
    }
    
    func customize(_ theme: AccountQuickActionsViewTheme) {
        self.theme = theme

        addActions(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    class func calculatePreferredSize(
        for theme: AccountQuickActionsViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let maxActionSize = CGSize((size.width, .greatestFiniteMagnitude))
        let buyActionSize = calculateActionPreferredSize(
            theme,
            for: theme.buyAction,
            fittingIn: maxActionSize
        )
        let requestsActionSize = calculateActionPreferredSize(
            theme,
            for: theme.requestsAction,
            fittingIn: maxActionSize
        )
        let swapActionSize = calculateActionPreferredSize(
            theme,
            for: theme.swapAction,
            fittingIn: maxActionSize
        )
        let moreActionSize = calculateActionPreferredSize(
            theme,
            for: theme.moreAction,
            fittingIn: maxActionSize
        )
        let preferredHeight = [
            buyActionSize.height,
            swapActionSize.height,
            requestsActionSize.height,
            moreActionSize.height
        ].max()!
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }

    class func calculateActionPreferredSize(
        _ theme: AccountQuickActionsViewTheme,
        for actionStyle: ButtonStyle,
        fittingIn size: CGSize
    ) -> CGSize {
        let width = theme.actionWidth
        let iconSize = actionStyle.icon?.first?.uiImage.size ?? .zero
        let titleSize = actionStyle.title?.text.boundingSize(
            multiline: true,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let preferredHeight =
            iconSize.height +
            theme.actionSpacingBetweenIconAndTitle +
            titleSize.height
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }
}

extension AccountQuickActionsView {
    private func addActions(_ theme: AccountQuickActionsViewTheme) {
        
        addSubview(contentBackgroundView)
        contentBackgroundView.addSubview(contentView)
        
        contentBackgroundView.backgroundColor = Colors.Defaults.background.uiColor
        
        contentView.distribution = .fillEqually
        contentView.alignment = .top
        contentView.spacing = theme.spacingBetweenActions
        
        contentBackgroundView.snp.makeConstraints {
            $0.top.leading.trailing == 0
            $0.bottom == theme.bottomPadding
        }
        
        contentView.snp.makeConstraints {
            $0.centerX == 0
            $0.top == 0
            $0.leading >= 0
            $0.bottom == theme.bottomPadding
            $0.trailing <= 0
        }
        
        addSwapAction(theme)
        addBuyAction(theme)
        addRequestsAction(theme)
        addMoreAction(theme)
    }

    private func addSwapAction(_ theme: AccountQuickActionsViewTheme) {
        swapActionView.customize(theme: theme.swapBadge)
        swapActionView.customizeAppearance(theme.swapAction)
        swapActionView.sizeToFit()
        customizeAction(
            swapActionView,
            theme
        )

        contentView.addArrangedSubview(swapActionView)

        startPublishing(
            event: .swap,
            for: swapActionView
        )
    }

    private func addBuyAction(_ theme: AccountQuickActionsViewTheme) {
        buyActionView.customizeAppearance(theme.buyAction)
        buyActionView.sizeToFit()
        customizeAction(
            buyActionView,
            theme
        )

        contentView.addArrangedSubview(buyActionView)

        startPublishing(
            event: .buy,
            for: buyActionView
        )
    }
    
    private func addRequestsAction(_ theme: AccountQuickActionsViewTheme) {
        requestsActionView.customizeAppearance(isRequestsBadgeVisible ? theme.requestsBadgeAction : theme.requestsAction)
        requestsActionView.sizeToFit()
        customizeAction(
            requestsActionView,
            theme
        )

        contentView.addArrangedSubview(requestsActionView)

        startPublishing(
            event: .requests,
            for: requestsActionView
        )
    }

    private func addMoreAction(_ theme: AccountQuickActionsViewTheme) {
        moreActionView.customizeAppearance(theme.moreAction)
        moreActionView.sizeToFit()
        customizeAction(
            moreActionView,
            theme
        )

        contentView.addArrangedSubview(moreActionView)

        startPublishing(
            event: .more,
            for: moreActionView
        )
    }

    private func customizeAction(
        _ actionView: MacaroonUIKit.Button,
        _ theme: AccountQuickActionsViewTheme
    ) {
        actionView.snp.makeConstraints {
            $0.fitToWidth(theme.actionWidth)
        }
    }
}

extension AccountQuickActionsView {
    private func makeActionView() -> MacaroonUIKit.Button {
        let titleAdjustmentY = theme.actionSpacingBetweenIconAndTitle
        return MacaroonUIKit.Button(.imageAtTopmost(
            padding: 0,
            titleAdjustmentY: titleAdjustmentY)
        )
    }

    private func makeBadgeActionView() -> BadgeButton {
        let titleAdjustmentY = theme.actionSpacingBetweenIconAndTitle
        let swapBadgeEdgeInsets = theme.swapBadgeEdgeInsets
        return BadgeButton(
            badgePosition: .topTrailing(swapBadgeEdgeInsets),
            .imageAtTopmost(
                padding: 0,
                titleAdjustmentY: titleAdjustmentY
            )
        )
    }
}

extension AccountQuickActionsView {
    enum Event {
        case swap
        case buy
        case requests
        case more
    }
}
