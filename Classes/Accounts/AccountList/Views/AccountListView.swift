// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  AccountListView.swift

import UIKit
import MacaroonUIKit

final class AccountListView: View {
    private lazy var theme = AccountListViewTheme()
    private lazy var titleLabel = UILabel()

    private(set) lazy var accountsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.cellSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.backgroundColor.color
        collectionView.registerCells(AccountPreviewCell.self)
        return collectionView
    }()

    private lazy var emptyStateView: SearchEmptyView = {
        let emptyStateView = SearchEmptyView()
        emptyStateView.setTitle("asset-not-found-title".localized)
        emptyStateView.setDetail("asset-not-found-detail".localized)
        return emptyStateView
    }()

    func customize(_ theme: AccountListViewTheme) {
        addTitleLabel(theme)
        addAccountCollectionView(theme)
    }

    func customizeAppearance(_ styleSheet: AccountListViewTheme) {}

    func prepareLayout(_ layoutSheet: AccountListViewTheme) {}
}

extension AccountListView {
    private func addTitleLabel(_ theme: AccountListViewTheme) {
        titleLabel.customizeAppearance(theme.titleLabel)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(theme.verticalPadding)
        }
    }
    
    private func addAccountCollectionView(_ theme: AccountListViewTheme) {
        addSubview(accountsCollectionView)
        accountsCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.verticalPadding)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(theme.accountListBottomInset)
        }

        accountsCollectionView.backgroundView = ContentStateView()
    }
}

extension AccountListView: ViewModelBindable {
    func bindData(_ viewModel: AccountListViewModel?) {
        titleLabel.text = viewModel?.title
    }

    func updateContentStateView(isEmpty: Bool) {
        accountsCollectionView.contentState = isEmpty ? .empty(emptyStateView) : .none
    }
}
