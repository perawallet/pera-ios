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

//   UISheetActionScreen.swift

import Foundation
import MacaroonUIKit
import UIKit
import MacaroonBottomSheet

/// <todo>:
/// Linear gradient / Blur is missing behind the actions context.
final class UISheetActionScreen:
    MacaroonUIKit.ScrollScreen,
    BottomSheetPresentable {
    var modalHeight: ModalHeight {
        return .compressed
    }

    private lazy var contextView = MacaroonUIKit.BaseView()
    private lazy var titleView = Label()
    private lazy var bodyView = Label()
    private lazy var actionsContextView = MacaroonUIKit.VStackView()

    private let sheet: UISheet
    private let theme: UISheetActionScreenTheme

    private var uiInteractions: [UIControlInteraction] = []

    init(
        sheet: UISheet,
        theme: UISheetActionScreenTheme
    ) {
        self.sheet = sheet
        self.theme = theme
        super.init()
    }

    override func prepareLayout() {
        super.prepareLayout()

        addContext()

        if sheet.actions.isEmpty {
            return
        }

        addActionsContext()
    }
}

extension UISheetActionScreen {
    private func addContext() {
        contentView.addSubview(contextView)

        let bottom = calculateBottomPaddingForContext()

        contextView.snp.makeConstraints {
            $0.top == theme.contextEdgeInsets.top
            $0.leading == theme.contextEdgeInsets.leading
            $0.trailing == theme.contextEdgeInsets.trailing
            $0.bottom == bottom
        }

        addTitle()
        addBody()
    }

    private func addTitle() {
        contextView.addSubview(titleView)
        titleView.customizeAppearance(theme.title)

        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        sheet.title?.load(in: titleView)
    }

    private func addBody() {
        contextView.addSubview(bodyView)
        bodyView.customizeAppearance(theme.body)

        bodyView.contentEdgeInsets.top = theme.spacingBetweenTitleAndBody
        bodyView.fitToIntrinsicSize()
        bodyView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
            $0.leading == 0
            $0.trailing == 0
            $0.bottom == 0
        }
        
        sheet.body?.load(in: bodyView)
    }

    private func addActionsContext() {
        view.addSubview(actionsContextView)
        actionsContextView.spacing = theme.actionSpacing

        actionsContextView.snp.makeConstraints {
            $0.leading == theme.actionsEdgeInsets.leading
            $0.trailing == theme.actionsEdgeInsets.trailing
            $0.setBottomPadding(
                theme.actionsEdgeInsets.bottom,
                inSafeAreaOf: view
            )
        }

        addActions()
    }

    private func addActions() {
        sheet.actions.forEach(addAction)
    }
}

extension UISheetActionScreen {
    private func addAction(
        _ action: UISheetAction
    ) {
        let actionView = createAction(
            action
        )

        let interaction = UIControlInteraction(
            actionView,
            handler: action.handler
        )

        uiInteractions.append(interaction)

        actionsContextView.addArrangedSubview(actionView)
    }

    private func createAction(
        _ action: UISheetAction
    ) -> UIButton {
        let actionView = MacaroonUIKit.Button()
        actionView.draw(corner: theme.actionCorner)
        actionView.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)

        actionView.customizeAppearance(
            theme.getActionStyle(
                action.style,
                title: action.title
            )
        )

        return actionView
    }
}

extension UISheetActionScreen {
    private func calculateBottomPaddingForContext() -> CGFloat {
        let bottom: CGFloat

        if sheet.actions.isEmpty {
            bottom = theme.contextEdgeInsets.bottom
        } else {
            let actionHeight: CGFloat = 53.5 /// <note>: Button height from view hiearchy.
            let actionsCount = sheet.actions.count
            let actionsHeight = actionsCount.cgFloat * actionHeight
            let actionsSpacing = (actionsCount - 1).cgFloat * theme.actionSpacing

            bottom =
            theme.contextEdgeInsets.bottom +
            actionsHeight +
            actionsSpacing +
            theme.actionsEdgeInsets.bottom
        }

        return bottom
    }
}

fileprivate extension UIControlInteraction {
    convenience init(
        _ control: UIControl,
        handler: @escaping Handler
    ) {
        self.init()

        link(control)
        activate(handler)
    }
}
