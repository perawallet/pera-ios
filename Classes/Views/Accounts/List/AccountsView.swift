//
//  AssetListView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountsView: BaseView {
    
    private(set) lazy var accountsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = SharedColors.warmWhite
        
        collectionView.register(AlgoAssetCell.self, forCellWithReuseIdentifier: AlgoAssetCell.reusableIdentifier)
        collectionView.register(AssetCell.self, forCellWithReuseIdentifier: AssetCell.reusableIdentifier)
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
    }
}
