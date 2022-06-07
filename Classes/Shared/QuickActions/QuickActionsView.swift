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
    private lazy var buyAlgoActionView =
        MacaroonUIKit.Button(.imageAtTopmost(padding: 0, titleAdjustmentY: Self.spacingBetweenActionIconAndTitle))
    private lazy var sendActionView =
        MacaroonUIKit.Button(.imageAtTopmost(padding: 0, titleAdjustmentY: Self.spacingBetweenActionIconAndTitle))
    private lazy var receiveActionView =
        MacaroonUIKit.Button(.imageAtTopmost(padding: 0, titleAdjustmentY: Self.spacingBetweenActionIconAndTitle))
    private lazy var scanQRActionView =
        MacaroonUIKit.Button(.imageAtTopmost(padding: 0, titleAdjustmentY: Self.spacingBetweenActionIconAndTitle))

    private static let spacingBetweenActionIconAndTitle: CGFloat = 15

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
        let oneButtonWidth = (size.width - (3 * theme.spacingBetweenActions)) / 4
        let font = theme.buyAlgoAction.font?.uiFont
        
        let firstSize = theme.buyAlgoAction.title?.text.string?.boundingSize(attributes: .font(font), multiline: true, fittingSize: CGSize(width: oneButtonWidth, height: .greatestFiniteMagnitude)) ?? .zero
        let secondSize = theme.sendAction.title?.text.string?.boundingSize(attributes: .font(font), fittingSize: CGSize(width: oneButtonWidth, height: .greatestFiniteMagnitude)) ?? .zero
        let thirdSize = theme.receiveAction.title?.text.string?.boundingSize(attributes: .font(font), multiline: true, fittingSize: CGSize(width: oneButtonWidth, height: .greatestFiniteMagnitude)) ?? .zero
        let fourthSize = theme.qrAction.title?.text.string?.boundingSize(attributes: .font(font), multiline: true, fittingSize: CGSize(width: oneButtonWidth, height: .greatestFiniteMagnitude)) ?? .zero
        
        let firstMax = max(firstSize.height.rounded(), secondSize.height.rounded())
        let secondMax = max(thirdSize.height.rounded(), fourthSize.height.rounded())
        
        let imageHeight = theme.buyAlgoAction.icon?[.normal]?.height ?? 48.0
        
        let totalHeight = max(firstMax, secondMax) + imageHeight + spacingBetweenActionIconAndTitle
        return CGSize((size.width, totalHeight))
    }
}


extension QuickActionsView {
    private func addActions(
        _ theme: QuickActionsViewTheme
    ) {
        addSubview(actionsView)
        actionsView.distribution = .fillEqually
        actionsView.spacing = theme.spacingBetweenActions
        actionsView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        addBuyAction(theme)
        addSendAction(theme)
        addReceiveAction(theme)
        addQRAction(theme)
    }

    private func addBuyAction(
        _ theme: QuickActionsViewTheme
    ) {
        buyAlgoActionView.customizeAppearance(theme.buyAlgoAction)
        actionsView.addArrangedSubview(buyAlgoActionView)

        startPublishing(
            event: .buyAlgo,
            for: buyAlgoActionView
        )
    }

    private func addSendAction(
        _ theme: QuickActionsViewTheme
    ) {
        sendActionView.customizeAppearance(theme.sendAction)
        actionsView.addArrangedSubview(sendActionView)

        startPublishing(
            event: .send,
            for: sendActionView
        )
    }

    private func addReceiveAction(
        _ theme: QuickActionsViewTheme
    ) {
        receiveActionView.customizeAppearance(theme.receiveAction)
        actionsView.addArrangedSubview(receiveActionView)

        startPublishing(
            event: .receive,
            for: receiveActionView
        )
    }

    private func addQRAction(
        _ theme: QuickActionsViewTheme
    ) {
        scanQRActionView.customizeAppearance(theme.qrAction)
        actionsView.addArrangedSubview(scanQRActionView)

        startPublishing(
            event: .scanQR,
            for: scanQRActionView
        )
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
