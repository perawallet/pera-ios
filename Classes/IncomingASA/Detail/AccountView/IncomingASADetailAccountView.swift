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

//   IncomingASADetailAccountView.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class IncomingASADetailAccountView:
    View,
    ViewModelBindable,
    ListReusable {

    private lazy var contentView = UIView()
    private lazy var iconView = ImageView()
    private lazy var accountNameView = Label()
    private lazy var titleView = Label()
    
    func customize(_ theme: IncomingASADetailAccountViewTheme) {
        addTitle(theme)
        addAccountName(theme)
        addIcon(theme)
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    func bindData(_ viewModel: AccountListItemViewModel?) {
        iconView.load(from: viewModel?.icon)
        viewModel?.title?.primaryTitle?.load(in: accountNameView)
        String(localized: "title-account").load(in: titleView)
    }

    static func calculatePreferredSize(
        _ viewModel: AccountListItemViewModel?,
        for theme: IncomingASADetailAccountViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let width = size.width
        let height = theme.height
        return .init(width: width, height: height)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension IncomingASADetailAccountView {
    
    private func addTitle(
        _ theme: IncomingASADetailAccountViewTheme
    ) {
        titleView.customizeAppearance(theme.title)
        addSubview(titleView)
        
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing <= 0
        }
    }

    private func addAccountName(
        _ theme: IncomingASADetailAccountViewTheme
    ) {
        accountNameView.customizeAppearance(theme.accountNameTitle)

        addSubview(accountNameView)
        accountNameView.snp.makeConstraints {
            $0.top == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
    
    private func addIcon(
        _ theme: IncomingASADetailAccountViewTheme
    ) {
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.top == 0
            $0.bottom == 0
            $0.trailing.equalTo(accountNameView.snp.leading).offset(-12)
            $0.fitToSize(theme.iconSize)
        }
    }
}

