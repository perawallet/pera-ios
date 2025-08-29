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

//   RekeyedAccountInformationAccountItemView.swift

import MacaroonUIKit
import UIKit

final class RekeyedAccountInformationAccountItemView:
    View,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .performSourceAccountAction: UIBlockInteraction(),
        .performAuthAccountAction: UIBlockInteraction()
    ]

    private let contentView = MacaroonUIKit.VStackView()
    private let sourceAccountItemView = CombinedAccountListItemView()
    private let authAccountItemView = AccountListItemWithActionView()
    
    var universalWalletName: String? {
        get { sourceAccountItemView.universalWalletName }
        set { sourceAccountItemView.universalWalletName = newValue }
    }
    
    var onScanButtonTap: (() -> Void)? {
        get { sourceAccountItemView.onScanButtonTap }
        set { sourceAccountItemView.onScanButtonTap = newValue }
    }

    func customize(_ theme: RekeyedAccountInformationAccountItemViewTheme) {
        addContent(theme)
    }

    func bindData(_ viewModel: RekeyedAccountInformationAccountItemViewModel?) {
        
        if let accountViewModel = viewModel?.sourceAccount {
            sourceAccountItemView.update(accountViewModel: accountViewModel)
        }
        
        authAccountItemView.bindData(viewModel?.authAccount)
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

        addSourceAccountItem(theme)
        addDivider(theme)
        addAuthAccountItem(theme)
    }

    private func addSourceAccountItem(_ theme: RekeyedAccountInformationAccountItemViewTheme) {
        sourceAccountItemView.update(theme: theme.accountItem)

        contentView.addArrangedSubview(sourceAccountItemView)

        sourceAccountItemView.snp.makeConstraints {
            $0.greaterThanHeight(theme.accountItemMinHeight)
        }
        
        sourceAccountItemView.onCopyButtonTap = { [weak self] in
            self?.uiInteractions[.performSourceAccountAction]?.publish()
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

    private func addAuthAccountItem(_ theme: RekeyedAccountInformationAccountItemViewTheme) {
        authAccountItemView.customize(theme.accountItem)

        contentView.addArrangedSubview(authAccountItemView)

        authAccountItemView.snp.makeConstraints {
            $0.greaterThanHeight(theme.accountItemMinHeight)
        }
        
        authAccountItemView.onCopyButtonTap = { [weak self] in
            self?.uiInteractions[.performAuthAccountAction]?.publish()
        }
    }
}

extension RekeyedAccountInformationAccountItemView {
    enum Event {
        case performSourceAccountAction
        case performAuthAccountAction
    }
}
