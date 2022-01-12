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
//  AssetListView.swift

import UIKit

// <todo> This file will be removed after account screen integration.
class AccountsView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AccountsViewDelegate?
    
    private lazy var contentStateView = ContentStateView()
    
    private(set) lazy var accountsCollectionView: AssetsCollectionView = {
        let collectionView = AssetsCollectionView(containsPendingAssets: true)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = Colors.Background.primary
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 20.0, right: 20.0)
        
        collectionView.register(AlgoAssetCell.self, forCellWithReuseIdentifier: AlgoAssetCell.reusableIdentifier)
        collectionView.register(GovernanceComingSoonCell.self, forCellWithReuseIdentifier: GovernanceComingSoonCell.reusableIdentifier)
        collectionView.register(
            AccountHeaderSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: AccountHeaderSupplementaryView.reusableIdentifier
        )
        collectionView.register(
            AccountFooterSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: AccountFooterSupplementaryView.reusableIdentifier
        )
        collectionView.register(
            EmptyFooterSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: EmptyFooterSupplementaryView.reusableIdentifier
        )
        
        return collectionView
    }()
    
    override func prepareLayout() {
        setupAccountsCollectionViewLayout()
    }
}

extension AccountsView {
    private func setupAccountsCollectionViewLayout() {
        addSubview(accountsCollectionView)
        
        accountsCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        accountsCollectionView.backgroundView = contentStateView
    }
}

extension AccountsView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let listTopInset: CGFloat = 12.0
    }
}

protocol AccountsViewDelegate: AnyObject {
    func accountsViewDidTapQRButton(_ accountsView: AccountsView)
    func accountsViewDidTapAddButton(_ accountsView: AccountsView)
}
