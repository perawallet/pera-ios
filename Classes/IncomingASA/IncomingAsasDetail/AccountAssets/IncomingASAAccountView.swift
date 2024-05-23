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

//   IncomingASAAccountView.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class IncomingASAAccountView:
    View,
    ViewModelBindable,
    ListReusable {

    private lazy var accountItemView = AccountListItemView() //LedgerAccountCellView
    private lazy var dividerView = UIView()
    private lazy var assetsItemView = IncomingAsaListItemView()
    
    func customize(_ theme: IncomingASAAccountTheme) {
        addAccountItem(theme)
        addDividerView(theme)
        addAssetItem(theme)
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    func bindData(_ viewModel: IncomingASAAccountViewModel?) {
        let titleVM = IncomingAsaAssetNameViewModel(primaryTitle: "USDC", primaryTitleAccessory: "icon-trusted".uiImage, secondaryTitle: "P5VB…47QY", SecondSecondaryTitle: "+2 more")
        let vm = IncomingAsaAssetListItemViewModel(imageSource: "icon-algo-circle".uiImage, title: titleVM, primaryValue: "Amir", secondaryValue: "Daliri", secondSecondaryValue: "Test")
        assetsItemView.bindData(vm)
        
        guard let url = Bundle.main.url(forResource: "AccountMock", withExtension: "json") else {
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let account = try Account.decoded(data)
            accountItemView.bindData(AccountListItemViewModel(account))
        } catch {
            print("Failed to load or decode AccountA: \(error)")
            print("Failed to load or decode AccountA: \(error)")
            print("Failed to load or decode AccountA: \(error)")
        }

    }

    static func calculatePreferredSize(
        _ viewModel: IncomingASAAccountViewModel?,
        for theme: IncomingASAAccountTheme,
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
//        return CGSize((width, min(preferredHeight, size.height)))
        return CGSize(width: width, height: 200)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func prepareForReuse() {
        accountItemView.prepareForReuse()
        assetsItemView.prepareForReuse()
    }
}

extension IncomingASAAccountView {
    
    private func addAccountItem(_ theme: IncomingASAAccountTheme) {
        accountItemView.customize(theme.accountItem)

        addSubview(accountItemView)
        accountItemView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalToSuperview().inset(16)
        }
    }
    
    private func addDividerView(_ theme: IncomingASAAccountTheme) {
        dividerView.customizeAppearance(theme.divider)
        
        addSubview(dividerView)
        dividerView.snp.makeConstraints {
            $0.leading.equalTo(accountItemView.snp.leading).offset(48)
            $0.trailing.equalTo(accountItemView.snp.trailing)
            $0.top.equalTo(accountItemView.snp.bottom).offset(20)
            $0.height.equalTo(1)
        }
    }
    private func addAssetItem(_ theme: IncomingASAAccountTheme) {
        assetsItemView.customize(theme.assetItem)

        addSubview(assetsItemView)
        assetsItemView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(dividerView.snp.bottom).inset(20)
            $0.bottom.equalToSuperview().inset(theme.verticalInset)
        }

    }
}
