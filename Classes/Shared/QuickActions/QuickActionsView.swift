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

//   QuickActionsView.swift

import Foundation
import MacaroonUIKit
import SnapKit
import UIKit

final class QuickActionsView:
    View,
    ListReusable,
    UIInteractionObservable,
    UIControlInteractionPublisher {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .buyAlgo: UIControlInteraction(),
        .send: UIControlInteraction(),
        .receive: UIControlInteraction(),
        .scanQR: UIControlInteraction()
    ]

    private lazy var contentView = MacaroonUIKit.BaseView()
    private lazy var actionsView = HStackView()

    func customize(
        _ theme: QuickActionsViewTheme
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
        for theme: QuickActionsViewTheme,
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
        let receiveActionSize = calculateActionPreferredSize(
            for: theme.receiveAction,
            fittingIn: maxActionSize
        )
        let scanActionSize = calculateActionPreferredSize(
            for: theme.scanAction,
            fittingIn: maxActionSize
        )
        let preferredHeight = [
            buyActionSize.height,
            sendActionSize.height,
            receiveActionSize.height,
            scanActionSize.height
        ].max()!
        return CGSize(width: size.width, height: min(preferredHeight.ceil(), size.height))
    }

    class func calculateActionPreferredSize(
        for theme: QuickActionViewTheme,
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
            QuickActionViewTheme.spacingBetweenIconAndTitle +
            (titleSize?.height ?? 20)
        return CGSize(width: maxWidth, height: min(preferredHeight.ceil(), size.height))
    }
}


extension QuickActionsView {
    private func addActions(
        _ theme: QuickActionsViewTheme
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
        addSendAction(theme)
        addReceiveAction(theme)
        addQRAction(theme)
    }

    private func addBuyAction(
        _ theme: QuickActionsViewTheme
    ) {
        let buyAlgoActionView = createAction(theme.buyAlgoAction)
        actionsView.addArrangedSubview(buyAlgoActionView)

        startPublishing(
            event: .buyAlgo,
            for: buyAlgoActionView
        )
    }

    private func addSendAction(
        _ theme: QuickActionsViewTheme
    ) {
        let sendActionView = createAction(theme.sendAction)
        actionsView.addArrangedSubview(sendActionView)

        startPublishing(
            event: .send,
            for: sendActionView
        )
    }

    private func addReceiveAction(
        _ theme: QuickActionsViewTheme
    ) {
        let receiveActionView = createAction(theme.receiveAction)
        actionsView.addArrangedSubview(receiveActionView)

        startPublishing(
            event: .receive,
            for: receiveActionView
        )
    }

    private func addQRAction(
        _ theme: QuickActionsViewTheme
    ) {
        let scanActionView = createAction(theme.scanAction)
        actionsView.addArrangedSubview(scanActionView)

        startPublishing(
            event: .scanQR,
            for: scanActionView
        )
    }

    private func createAction(
        _ theme: QuickActionViewTheme
    ) -> UIControl {
        let actionView = MacaroonUIKit.Button(
            .imageAtTopmost(
                padding: 0,
                titleAdjustmentY: QuickActionViewTheme.spacingBetweenIconAndTitle
            )
        )
        actionView.customizeAppearance(theme.style)
        actionView.snp.makeConstraints {
            $0.fitToWidth(theme.width)
        }
        return actionView
    }
}

extension QuickActionsView {
    enum Event {
        case buyAlgo
        case send
        case receive
        case scanQR
    }
}
