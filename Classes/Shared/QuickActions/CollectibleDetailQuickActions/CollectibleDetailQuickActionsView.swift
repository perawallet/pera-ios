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

//   CollectibleDetailQuickActionsView.swift

import Foundation
import MacaroonUIKit
import SnapKit
import UIKit

final class CollectibleDetailQuickActionsView:
    View,
    ListReusable,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .send: TargetActionInteraction(),
        .copy: TargetActionInteraction(),
        .save: TargetActionInteraction(),
    ]

    private lazy var contentView = HStackView()
    private lazy var sendActionView = makeActionView()
    private lazy var copyActionView =  makeActionView()
    private lazy var saveActionView = makeActionView()

    private var theme: CollectibleDetailQuickActionsViewTheme!

    func customize(_ theme: CollectibleDetailQuickActionsViewTheme) {
        self.theme = theme

        addActions(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    class func calculatePreferredSize(
        for theme: CollectibleDetailQuickActionsViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let maxActionSize = CGSize((size.width, .greatestFiniteMagnitude))
        let sendActionSize = calculateActionPreferredSize(
            theme,
            for: theme.sendAction,
            fittingIn: maxActionSize
        )
        let copyActionSize = calculateActionPreferredSize(
            theme,
            for: theme.copyAction,
            fittingIn: maxActionSize
        )
        let saveActionSize = calculateActionPreferredSize(
            theme,
            for: theme.saveAction,
            fittingIn: maxActionSize
        )
        let preferredHeight = [
            sendActionSize.height,
            copyActionSize.height,
            saveActionSize.height
        ].max()!
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }

    class func calculateActionPreferredSize(
        _ theme: CollectibleDetailQuickActionsViewTheme,
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

extension CollectibleDetailQuickActionsView {
    private func addActions(_ theme: CollectibleDetailQuickActionsViewTheme) {
        addSubview(contentView)
        contentView.distribution = .fillEqually
        contentView.alignment = .top
        contentView.spacing = theme.spacingBetweenActions
        contentView.snp.makeConstraints {
            $0.centerX == 0
            $0.top == 0
            $0.leading >= 0
            $0.bottom == 0
            $0.trailing <= 0
        }

        addSendAction(theme)
        addCopyAction(theme)
        addSaveAction(theme)
    }

    private func addSendAction(_ theme: CollectibleDetailQuickActionsViewTheme) {
        sendActionView.customizeAppearance(theme.sendAction)
        customizeAction(
            sendActionView,
            theme
        )

        contentView.addArrangedSubview(sendActionView)

        startPublishing(
            event: .send,
            for: sendActionView
        )
    }

    private func addCopyAction(_ theme: CollectibleDetailQuickActionsViewTheme) {
        copyActionView.customizeAppearance(theme.copyAction)
        customizeAction(
            copyActionView,
            theme
        )

        contentView.addArrangedSubview(copyActionView)

        startPublishing(
            event: .copy,
            for: copyActionView
        )
    }
    
    private func addSaveAction(_ theme: CollectibleDetailQuickActionsViewTheme) {
        saveActionView.customizeAppearance(theme.saveAction)
        customizeAction(
            saveActionView,
            theme
        )

        contentView.addArrangedSubview(saveActionView)

        startPublishing(
            event: .save,
            for: saveActionView
        )
    }

    private func customizeAction(
        _ actionView: MacaroonUIKit.Button,
        _ theme: CollectibleDetailQuickActionsViewTheme
    ) {
        actionView.snp.makeConstraints {
            $0.fitToWidth(theme.actionWidth)
        }
    }
}

extension CollectibleDetailQuickActionsView {
    private func makeActionView() -> MacaroonUIKit.Button {
        let titleAdjustmentY = theme.actionSpacingBetweenIconAndTitle
        return MacaroonUIKit.Button(.imageAtTopmost(
            padding: 0,
            titleAdjustmentY: titleAdjustmentY)
        )
    }
}

extension CollectibleDetailQuickActionsView {
    enum Event {
        case send
        case copy
        case save
    }
}
