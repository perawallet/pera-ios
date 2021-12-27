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
import MacaroonUIKit

final class LedgerAccountDetailView: View {
    private lazy var theme = LedgerAccountDetailViewTheme()

    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.cellSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        collectionView.contentInset = UIEdgeInsets(theme.contentInset)
        collectionView.register(AccountPreviewCell.self)
        collectionView.register(AssetPreviewCell.self)
        collectionView.register(header: LedgerAccountDetailSectionHeaderReusableView.self)
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize()
    }

    private func customize() {
        addCollectionView()
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension LedgerAccountDetailView {
    private func addCollectionView() {
        addSubview(collectionView)
        collectionView.pinToSuperview()
    }
}

// MARK: - AccountPreviewCell

final class AccountPreviewCell: BaseCollectionViewCell<AccountPreviewView> {
    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(AccountPreviewViewTheme())
    }

    private func customize(_ theme: AccountPreviewViewTheme) {
        contextView.customize(theme)
    }

    func bindData(_ viewModel: AccountPreviewViewModel) {
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
