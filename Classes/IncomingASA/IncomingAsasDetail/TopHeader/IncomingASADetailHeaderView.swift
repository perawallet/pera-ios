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

//   IncomingASADetailHeaderView.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class IncomingASADetailHeaderView:
    View,
    ViewModelBindable,
    ListReusable {

    private lazy var accountItemView = AccountListItemView()
    private lazy var dividerView = UIView()
    private lazy var assetsItemView = IncomingASAItemView()
    
    func customize(_ theme: IncomingASADetailHeaderTheme) {
        addAccountItem(theme)
        addDividerView(theme)
        addAssetItem(theme)
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    func bindData(_ viewModel: IncomingASADetailHeaderViewModel?) {
        assetsItemView.bindData(viewModel?.assetItem)
        accountItemView.bindData(viewModel?.accountItem)
    }

    static func calculatePreferredSize(
        _ viewModel: IncomingASADetailHeaderViewModel?,
        for theme: IncomingASADetailHeaderTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let accountItemWidth =
            width -
            theme.horizontalInset -
            theme.horizontalInset -
            theme.infoIconSize.w -
            theme.horizontalInset

        let maxAccountItemSize = CGSize(width: accountItemWidth, height: .greatestFiniteMagnitude)
        let accountItemSize = AccountListItemView.calculatePreferredSize(
            viewModel.accountItem,
            for: theme.accountItem,
            fittingIn: maxAccountItemSize
        )
        let preferredHeight =
            theme.verticalInset +
            accountItemSize.height +
            theme.verticalInset
        return CGSize(width: width, height: theme.height)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func prepareForReuse() {
        accountItemView.prepareForReuse()
        assetsItemView.prepareForReuse()
    }
}

extension IncomingASADetailHeaderView {
    
    private func addAccountItem(_ theme: IncomingASADetailHeaderTheme) {
        accountItemView.customize(theme.accountItem)

        addSubview(accountItemView)
        accountItemView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalToSuperview().inset(theme.accountTopInset)
        }
    }
    
    private func addDividerView(_ theme: IncomingASADetailHeaderTheme) {
        dividerView.customizeAppearance(theme.divider)
        
        addSubview(dividerView)
        dividerView.snp.makeConstraints {
            $0.leading.equalTo(accountItemView.snp.leading).offset(theme.dividerLeadingInset)
            $0.trailing.equalTo(accountItemView.snp.trailing)
            $0.top.equalTo(accountItemView.snp.bottom).offset(theme.dividerTopInset)
            $0.height.equalTo(theme.dividerHeight)
        }
    }
    private func addAssetItem(_ theme: IncomingASADetailHeaderTheme) {
        assetsItemView.customize(theme.assetItem)

        addSubview(assetsItemView)
        assetsItemView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(dividerView.snp.bottom).inset(theme.dividerTopInset)
            $0.bottom.equalToSuperview().inset(theme.verticalInset)
        }

    }
}
