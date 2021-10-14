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
//  LedgerAccountDetailView.swift

import UIKit
import Macaroon

final class LedgerAccountDetailView: View {
    private lazy var theme = LedgerAccountDetailViewTheme()

    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.cellSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.backgroundColor.color
        collectionView.contentInset = UIEdgeInsets(theme.contentInset)
        collectionView.registerCells(AccountPreviewCell.self, AssetPreviewCell.self)
        collectionView.registerSupplementaryView(LedgerAccountDetailSectionHeaderReusableView.self, of: .header)
        return collectionView
    }()

    func customize(_ theme: LedgerAccountDetailViewTheme) {
        addCollectionView(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension LedgerAccountDetailView {
    private func addCollectionView(_ theme: LedgerAccountDetailViewTheme) {
        addSubview(collectionView)
        collectionView.pinToSuperview()
    }
}

// MARK: - AccountPreviewCell

final class AccountPreviewCell: BaseCollectionViewCell<AccountPreviewView> {
    func customize(_ theme: AccountPreviewViewTheme) {
        contextView.customize(theme)
    }

    func bindData(_ viewModel: AccountPreviewViewModel) {
        contextView.bindData(viewModel)
    }

    func bindData(_ viewModel: AccountNameViewModel) {
        contextView.bindData(viewModel)
    }

    func bindData(_ viewModel: AuthAccountNameViewModel) {
        contextView.bindData(viewModel)
    }
}

// MARK: - AssetPreviewCell

final class AssetPreviewCell: BaseCollectionViewCell<AssetPreviewView> {
    func customize(_ theme: AssetPreviewViewTheme) {
        contextView.customize(theme)
    }

    func bindData(_ viewModel: AssetPreviewViewModel) {
        contextView.bindData(viewModel)
    }
}

// MARK: - LedgerAccountDetailSectionHeaderReusableView

final class LedgerAccountDetailSectionHeaderReusableView: BaseSupplementaryView<LedgerAccountDetailSectionHeaderView> {
    func bindData(_ viewModel: LedgerAccountDetailSectionHeaderViewModel?) {
        contextView.bindData(viewModel)
    }
}
