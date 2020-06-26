//
//  AssetsCollectionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 22.06.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class AssetsCollectionView: UICollectionView {
    
    init(containsPendingAssets: Bool) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        super.init(frame: .zero, collectionViewLayout: flowLayout)
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        registerAssetCells()
        
        if containsPendingAssets {
            registerPendingAssetCells()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func registerAssetCells() {
        register(AssetCell.self, forCellWithReuseIdentifier: AssetCell.reusableIdentifier)
        register(OnlyNameAssetCell.self, forCellWithReuseIdentifier: OnlyNameAssetCell.reusableIdentifier)
        register(OnlyUnitNameAssetCell.self, forCellWithReuseIdentifier: OnlyUnitNameAssetCell.reusableIdentifier)
        register(UnnamedAssetCell.self, forCellWithReuseIdentifier: UnnamedAssetCell.reusableIdentifier)
        register(UnverifiedAssetCell.self, forCellWithReuseIdentifier: UnverifiedAssetCell.reusableIdentifier)
        register(
            UnverifiedOnlyNameAssetCell.self,
            forCellWithReuseIdentifier: UnverifiedOnlyNameAssetCell.reusableIdentifier
        )
        register(
            UnverifiedOnlyUnitNameAssetCell.self,
            forCellWithReuseIdentifier: UnverifiedOnlyUnitNameAssetCell.reusableIdentifier
        )
        register(UnverifiedUnnamedAssetCell.self, forCellWithReuseIdentifier: UnverifiedUnnamedAssetCell.reusableIdentifier)
    }
    
    private func registerPendingAssetCells() {
        register(PendingAssetCell.self, forCellWithReuseIdentifier: PendingAssetCell.reusableIdentifier)
        register(PendingOnlyNameAssetCell.self, forCellWithReuseIdentifier: PendingOnlyNameAssetCell.reusableIdentifier)
        register(
            PendingOnlyUnitNameAssetCell.self,
            forCellWithReuseIdentifier: PendingOnlyUnitNameAssetCell.reusableIdentifier
        )
        register(PendingUnnamedAssetCell.self, forCellWithReuseIdentifier: PendingUnnamedAssetCell.reusableIdentifier)
        register(PendingUnverifiedAssetCell.self, forCellWithReuseIdentifier: PendingUnverifiedAssetCell.reusableIdentifier)
        register(
            UnverifiedOnlyNameAssetCell.self,
            forCellWithReuseIdentifier: UnverifiedOnlyNameAssetCell.reusableIdentifier
        )
        register(
            PendingUnverifiedOnlyUnitNameAssetCell.self,
            forCellWithReuseIdentifier: PendingUnverifiedOnlyUnitNameAssetCell.reusableIdentifier
        )
        register(
            PendingUnverifiedUnnamedAssetCell.self,
            forCellWithReuseIdentifier: PendingUnverifiedUnnamedAssetCell.reusableIdentifier
        )
    }
}
