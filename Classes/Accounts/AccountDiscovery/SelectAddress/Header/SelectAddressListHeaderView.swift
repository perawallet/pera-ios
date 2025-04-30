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

//   SelectAddressListHeaderView.swift

import UIKit
import MacaroonUIKit

final class SelectAddressListHeaderView:
    View,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .performAction: TargetActionInteraction()
    ]
    
    var state: SelectAddressListHeaderItemState = .selectAll {
        didSet { updateStateIfNeeded(old: oldValue) }
    }

    private lazy var infoView = Label()
    private lazy var actionView = MacaroonUIKit.Button(theme.actionLayout)

    private var theme: SelectAddressListHeaderTheme!

    func customize(
        _ theme: SelectAddressListHeaderTheme
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
        _ viewModel: SelectAddressListHeaderViewModel?
    ) {
        guard let viewModel = viewModel else {
            infoView.clearText()
            return
        }
        viewModel.title?.load(in: infoView)
    }
}

extension SelectAddressListHeaderView {
    private func addBackground(
        _ theme: SelectAddressListHeaderTheme
    ) {
        customizeAppearance(theme.background)
    }

    private func addInfo(
        _ theme: SelectAddressListHeaderTheme
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
        _ theme: SelectAddressListHeaderTheme
    ) {
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

        updateAction(.selectAll)
    }
}

extension SelectAddressListHeaderView {
    func updateState(_ state: SelectAddressListHeaderItemState) {
        updateAction(state)
    }

    func updateAction(_ state: SelectAddressListHeaderItemState) {
        let actionStyle = theme[state]

        actionView.customizeAppearance(actionStyle)
    }
}

extension SelectAddressListHeaderView {
    private func updateStateIfNeeded(old: SelectAddressListHeaderItemState) {
        if state != old {
            updateState(state)
        }
    }
}

extension SelectAddressListHeaderView {
    enum Event {
        case performAction
    }
}
