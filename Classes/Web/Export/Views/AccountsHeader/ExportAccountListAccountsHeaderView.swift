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

//   ExportAccountListAccountsHeaderView.swift

import UIKit
import MacaroonUIKit

final class ExportAccountListAccountsHeaderView:
    View,
    ViewModelBindable,
    ListReusable,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .performAction: TargetActionInteraction()
    ]

    private lazy var infoView = Label()
    private lazy var actionView = MacaroonUIKit.Button(theme.actionLayout)

    private var theme: ExportAccountListAccountsHeaderViewTheme!

    func customize(
        _ theme: ExportAccountListAccountsHeaderViewTheme
    ) {
        self.theme = theme

        addBackground(theme)
        addInfo(theme)
        addAction(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: ExportAccountListAccountsHeaderViewModel?
    ) {
        if let info = viewModel?.info {
            info.load(in: infoView)
        } else {
            infoView.clearText()
        }

        if let actionStyle = viewModel?.actionStyle {
            actionView.customizeAppearance(actionStyle)
        } else {
            actionView.resetAppearance()
        }
    }

    class func calculatePreferredSize(
        _ viewModel: ExportAccountListAccountsHeaderViewModel?,
        for theme: ExportAccountListAccountsHeaderViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width - theme.minimumHorizontalSpacing
        let infoSize = viewModel.info?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero

        let buttonHeight: LayoutMetric = 24
        let preferredHeight = max(infoSize.height, buttonHeight)
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension ExportAccountListAccountsHeaderView {
    private func addBackground(
        _ theme: ExportAccountListAccountsHeaderViewTheme
    ) {
        customizeAppearance(theme.background)
    }

    private func addInfo(
        _ theme: ExportAccountListAccountsHeaderViewTheme
    ) {
        infoView.customizeAppearance(theme.info)

        addSubview(infoView)
        infoView.snp.makeConstraints {
            $0.width >= (self - theme.minimumHorizontalSpacing) * theme.infoMinWidthRatio
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }
    }

    private func addAction(
        _ theme: ExportAccountListAccountsHeaderViewTheme
    ) {
        actionView.customizeAppearance(theme.action)

        addSubview(actionView)
        actionView.fitToIntrinsicSize()
        actionView.snp.makeConstraints {
            $0.top == 0
            $0.leading >= infoView.snp.trailing + theme.minimumHorizontalSpacing
            $0.trailing == 0
            $0.bottom == 0
        }

        startPublishing(
            event: .performAction,
            for: actionView
        )
    }
}

extension ExportAccountListAccountsHeaderView {
    enum Event {
        case performAction
    }
}
