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

//   HomeQuickActionsView.swift

import Foundation
import MacaroonUIKit
import SnapKit
import UIKit

final class HomeQuickActionsView:
    View,
    ListReusable,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .buyAlgo: TargetActionInteraction(),
        .swap: TargetActionInteraction(),
        .send: TargetActionInteraction(),
        .scanQR: TargetActionInteraction()
    ]

    private lazy var contentView = MacaroonUIKit.BaseView()
    private lazy var actionsView = HStackView()

    func customize(
        _ theme: HomeQuickActionsViewTheme
    ) {
        addActions(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    class func calculatePreferredSize(
        for theme: HomeQuickActionsViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let maxActionSize = CGSize(width: size.width, height: .greatestFiniteMagnitude)
        let buyActionSize = calculateActionPreferredSize(
            for: theme.buyAlgoAction,
            fittingIn: maxActionSize
        )
        let sendActionSize = calculateActionPreferredSize(
            for: theme.sendAction,
            fittingIn: maxActionSize
        )
        let swapActionSize = calculateActionPreferredSize(
            for: theme.swapAction,
            fittingIn: maxActionSize
        )
        let scanActionSize = calculateActionPreferredSize(
            for: theme.scanAction,
            fittingIn: maxActionSize
        )
        let preferredHeight = [
            buyActionSize.height,
            swapActionSize.height,
            sendActionSize.height,
            scanActionSize.height
        ].max()!
        return CGSize(width: size.width, height: min(preferredHeight.ceil(), size.height))
    }

    class func calculateActionPreferredSize(
        for theme: HomeQuickActionViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let font = theme.style.font?.uiFont
        let maxWidth = min(theme.width, size.width)
        let iconSize = theme.icon?.uiImage.size
        let titleSize = theme.title?.boundingSize(
            attributes: .font(font),
            multiline: true,
            fittingSize: CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        )
        let preferredHeight =
            (iconSize?.height ?? 48) +
            HomeQuickActionViewTheme.spacingBetweenIconAndTitle +
            (titleSize?.height ?? 20)
        return CGSize(width: maxWidth, height: min(preferredHeight.ceil(), size.height))
    }
}

extension HomeQuickActionsView {
    private func addActions(
        _ theme: HomeQuickActionsViewTheme
    ) {
        addSubview(actionsView)
        actionsView.distribution = .equalSpacing
        actionsView.spacing = theme.spacingBetweenActions
        actionsView.snp.makeConstraints {
            $0.centerX == 0
            $0.top == 0
            $0.leading <= theme.maxContentHorizontalInsets.leading
            $0.bottom == 0
            $0.trailing >= theme.maxContentHorizontalInsets.trailing
        }

        addBuyAction(theme)
        addSwapAction(theme)
        addSendAction(theme)
        addQRAction(theme)
    }

    private func addBuyAction(
        _ theme: HomeQuickActionsViewTheme
    ) {
        let buyAlgoActionView = createAction(theme.buyAlgoAction)
        actionsView.addArrangedSubview(buyAlgoActionView)

        startPublishing(
            event: .buyAlgo,
            for: buyAlgoActionView
        )
    }

    private func addSwapAction(
        _ theme: HomeQuickActionsViewTheme
    ) {
        let swapActionTheme = theme.swapAction

        let swapActionView = BadgeButton(
            badgePosition: .topTrailing(
                theme.swapNewBadgeEdgeInsets
            ),
            .imageAtTopmost(
                padding: 0,
                titleAdjustmentY: HomeQuickActionViewTheme.spacingBetweenIconAndTitle
            )
        )

        swapActionView.customize(theme: theme.swapNewBadge)
        swapActionView.customizeAppearance(swapActionTheme.style)

        swapActionView.snp.makeConstraints {
            $0.fitToWidth(swapActionTheme.width)
        }

        actionsView.addArrangedSubview(swapActionView)

        startPublishing(
            event: .swap,
            for: swapActionView
        )
    }

    private func addSendAction(
        _ theme: HomeQuickActionsViewTheme
    ) {
        let sendActionView = createAction(theme.sendAction)
        actionsView.addArrangedSubview(sendActionView)

        startPublishing(
            event: .send,
            for: sendActionView
        )
    }

    private func addQRAction(
        _ theme: HomeQuickActionsViewTheme
    ) {
        let scanActionView = createAction(theme.scanAction)
        actionsView.addArrangedSubview(scanActionView)

        startPublishing(
            event: .scanQR,
            for: scanActionView
        )
    }

    private func createAction(
        _ theme: HomeQuickActionViewTheme
    ) -> UIControl {
        let actionView = MacaroonUIKit.Button(
            .imageAtTopmost(
                padding: 0,
                titleAdjustmentY: HomeQuickActionViewTheme.spacingBetweenIconAndTitle
            )
        )
        actionView.customizeAppearance(theme.style)
        actionView.snp.makeConstraints {
            $0.fitToWidth(theme.width)
        }
        return actionView
    }
}

extension HomeQuickActionsView {
    enum Event {
        case buyAlgo
        case swap
        case send
        case scanQR
    }
}
