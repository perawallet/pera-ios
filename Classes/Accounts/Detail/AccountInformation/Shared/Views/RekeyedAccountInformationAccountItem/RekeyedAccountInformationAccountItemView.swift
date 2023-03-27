// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   RekeyedAccountInformationAccountItemView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class RekeyedAccountInformationAccountItemView:
    View,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .performFromAccountAction: UIBlockInteraction(),
        .performToAccountAction: UIBlockInteraction()
    ]

    private lazy var contentView = MacaroonUIKit.VStackView()
    private lazy var fromAccountItemView = AccountListItemWithActionView()
    private lazy var toAccountItemView = AccountListItemWithActionView()

    func customize(_ theme: RekeyedAccountInformationAccountItemViewTheme) {
        addContent(theme)
    }

    func bindData(_ viewModel: RekeyedAccountInformationAccountItemViewModel?) {
        fromAccountItemView.bindData(viewModel?.from)
        toAccountItemView.bindData(viewModel?.to)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension RekeyedAccountInformationAccountItemView {
    private func addContent(_ theme: RekeyedAccountInformationAccountItemViewTheme) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        addFromAccountItem(theme)
        addDivider(theme)
        addToAccountItem(theme)
    }

    private func addFromAccountItem(_ theme: RekeyedAccountInformationAccountItemViewTheme) {
        fromAccountItemView.customize(theme.accountItem)

        contentView.addArrangedSubview(fromAccountItemView)

        fromAccountItemView.snp.makeConstraints {
            $0.greaterThanHeight(theme.accountItemMinHeight)
        }

        fromAccountItemView.startObserving(event: .performAction) {
            [unowned self] in
            let interaction = self.uiInteractions[.performFromAccountAction]
            interaction?.publish()
        }
    }

    private func addDivider(_ theme: RekeyedAccountInformationAccountItemViewTheme) {
        let dividerView = UIView()
        contentView.addArrangedSubview(dividerView)

        let leadingLineView = UIView()
        leadingLineView.customizeAppearance(theme.dividerLine)

        dividerView.addSubview(leadingLineView)
        leadingLineView.snp.makeConstraints {
            $0.centerY == 0
            $0.leading == 0
            $0.greaterThanWidth(theme.dividerLineMinWidth)
            $0.fitToHeight(theme.dividerLineHeight)
        }

        let titleView = UILabel()
        titleView.customizeAppearance(theme.dividerTitle)

        dividerView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.centerX == 0
            $0.top == 0
            $0.leading == leadingLineView.snp.trailing + theme.spacingBetweenDividerTitleAndLine
            $0.bottom == 0
        }

        let trailingLineView = UIView()
        trailingLineView.customizeAppearance(theme.dividerLine)

        dividerView.addSubview(trailingLineView)
        trailingLineView.snp.makeConstraints {
            $0.centerY == 0
            $0.trailing == 0
            $0.leading == titleView.snp.trailing + theme.spacingBetweenDividerTitleAndLine
            $0.greaterThanWidth(theme.dividerLineMinWidth)
            $0.fitToHeight(theme.dividerLineHeight)
        }
    }

    private func addToAccountItem(_ theme: RekeyedAccountInformationAccountItemViewTheme) {
        toAccountItemView.customize(theme.accountItem)

        contentView.addArrangedSubview(toAccountItemView)

        toAccountItemView.snp.makeConstraints {
            $0.greaterThanHeight(theme.accountItemMinHeight)
        }

        toAccountItemView.startObserving(event: .performAction) {
            [unowned self] in
            let interaction = self.uiInteractions[.performToAccountAction]
            interaction?.publish()
        }
    }
}

extension RekeyedAccountInformationAccountItemView {
    enum Event {
        case performFromAccountAction
        case performToAccountAction
    }
}
