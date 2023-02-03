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
import UIKit
import MacaroonUIKit
import MacaroonBottomSheet

final class UISheetActionScreen:
    MacaroonUIKit.ScrollScreen,
    BottomSheetScrollPresentable {
    var modalHeight: ModalHeight {
        return .compressed
    }

    private lazy var contextView = MacaroonUIKit.BaseView()
    private lazy var imageView = ImageView()
    private lazy var titleView = Label()
    private lazy var bodyView = Label()
    private lazy var actionsContextView = MacaroonUIKit.VStackView()

    private let sheet: UISheet
    private let theme: UISheetActionScreenTheme

    private var uiInteractions: [TargetActionInteraction] = []

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

        addBackground()
        addContext()

        if !sheet.actions.isEmpty {
            addActionsContext()
        }
    }

    override func addFooter() {
        super.addFooter()

        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        backgroundGradient.locations = [ 0, 0.3, 1 ]

        footerBackgroundEffect = LinearGradientEffect(gradient: backgroundGradient)
    }
}

extension UISheetActionScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addContext() {
        contentView.addSubview(contextView)

        contextView.snp.makeConstraints {
            $0.top == theme.contextEdgeInsets.top
            $0.leading == theme.contextEdgeInsets.leading
            $0.trailing == theme.contextEdgeInsets.trailing
            $0.bottom == theme.contextEdgeInsets.bottom
        }

        addImage()
        addTitle()
        addBody()
    }

    private func addImage() {
        contextView.addSubview(imageView)
        imageView.customizeAppearance(theme.image)

        imageView.fitToIntrinsicSize()
        imageView.contentEdgeInsets = theme.imageLayoutOffset
        imageView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        imageView.image = sheet.image?.uiImage
    }

    private func addTitle() {
        contextView.addSubview(titleView)
        titleView.customizeAppearance(theme.title)

        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == imageView.snp.bottom
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
        footerView.addSubview(actionsContextView)
        actionsContextView.spacing = theme.actionSpacing

        actionsContextView.snp.makeConstraints {
            $0.top == theme.actionsEdgeInsets.top
            $0.leading == theme.actionsEdgeInsets.leading
            $0.trailing == theme.actionsEdgeInsets.trailing
            $0.bottom == theme.actionsEdgeInsets.bottom
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
        let actionView = createActionView(action)

        let interaction = TargetActionInteraction()
        interaction.setSelector(action.handler)
        interaction.attach(to: actionView)
        uiInteractions.append(interaction)

        actionsContextView.addArrangedSubview(actionView)
    }

    private func createActionView(
        _ action: UISheetAction
    ) -> UIButton {
        let actionView = MacaroonUIKit.Button()
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
