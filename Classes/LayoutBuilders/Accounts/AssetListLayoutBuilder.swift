//
//  AssetListLayoutBuilder.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

struct AssetListLayoutBuilder {
    func dequeueAssetCells(
        in collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath,
        for assetDetail: AssetDetail
    ) -> BaseAssetCell {
        if assetDetail.isVerified {
            return dequeueVerifiedAssetCells(in: collectionView, cellForItemAt: indexPath, for: assetDetail)
        } else {
            return dequeueUnverifiedAssetCells(in: collectionView, cellForItemAt: indexPath, for: assetDetail)
        }
    }
    
    func dequeuePendingAssetCells(
        in collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath,
        for assetDetail: AssetDetail
    ) -> BasePendingAssetCell {
        if assetDetail.isVerified {
            return dequeuePendingVerifiedAssetCells(in: collectionView, cellForItemAt: indexPath, for: assetDetail)
        } else {
            return dequeuePendingUnverifiedAssetCells(in: collectionView, cellForItemAt: indexPath, for: assetDetail)
        }
    }
}
    
extension AssetListLayoutBuilder {
    private func dequeuePendingVerifiedAssetCells(
        in collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath,
        for assetDetail: AssetDetail
    ) -> BasePendingAssetCell {
        if assetDetail.hasBothDisplayName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PendingAssetCell.reusableIdentifier,
                for: indexPath
            ) as? PendingAssetCell {
                return cell
            }
        }
        
        if assetDetail.hasOnlyAssetName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PendingOnlyNameAssetCell.reusableIdentifier,
                for: indexPath
            ) as? PendingOnlyNameAssetCell {
                return cell
            }
        }
        
        if assetDetail.hasOnlyUnitName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PendingOnlyUnitNameAssetCell.reusableIdentifier,
                for: indexPath
            ) as? PendingOnlyUnitNameAssetCell {
                return cell
            }
        }
        
        if assetDetail.hasNoDisplayName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PendingUnnamedAssetCell.reusableIdentifier,
                for: indexPath
            ) as? PendingUnnamedAssetCell {
                return cell
            }
        }
        
        fatalError("Unexpected Element")
    }
    
    private func dequeuePendingUnverifiedAssetCells(
        in collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath,
        for assetDetail: AssetDetail
    ) -> BasePendingAssetCell {
        if assetDetail.hasBothDisplayName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PendingUnverifiedAssetCell.reusableIdentifier,
                for: indexPath
            ) as? PendingUnverifiedAssetCell {
                return cell
            }
        }
        
        if assetDetail.hasOnlyAssetName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PendingUnverifiedOnlyNameAssetCell.reusableIdentifier,
                for: indexPath
            ) as? PendingUnverifiedOnlyNameAssetCell {
                return cell
            }
        }
        
        if assetDetail.hasOnlyUnitName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PendingUnverifiedOnlyUnitNameAssetCell.reusableIdentifier,
                for: indexPath
            ) as? PendingUnverifiedOnlyUnitNameAssetCell {
                return cell
            }
        }
        
        if assetDetail.hasNoDisplayName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PendingUnverifiedUnnamedAssetCell.reusableIdentifier,
                for: indexPath
            ) as? PendingUnverifiedUnnamedAssetCell {
                return cell
            }
        }
        
        fatalError("Unexpected Element")
    }
    
    private func dequeueVerifiedAssetCells(
        in collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath,
        for assetDetail: AssetDetail
    ) -> BaseAssetCell {
        if assetDetail.hasBothDisplayName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AssetCell.reusableIdentifier,
                for: indexPath
            ) as? AssetCell {
                return cell
            }
        }
        
        if assetDetail.hasOnlyAssetName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: OnlyNameAssetCell.reusableIdentifier,
                for: indexPath
            ) as? OnlyNameAssetCell {
                return cell
            }
        }
        
        if assetDetail.hasOnlyUnitName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: OnlyUnitNameAssetCell.reusableIdentifier,
                for: indexPath
            ) as? OnlyUnitNameAssetCell {
                return cell
            }
        }
        
        if assetDetail.hasNoDisplayName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UnnamedAssetCell.reusableIdentifier,
                for: indexPath
            ) as? UnnamedAssetCell {
                return cell
            }
        }
        
        fatalError("Unexpected Element")
    }
    
    private func dequeueUnverifiedAssetCells(
        in collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath,
        for assetDetail: AssetDetail
    ) -> BaseAssetCell {
        if assetDetail.hasBothDisplayName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UnverifiedAssetCell.reusableIdentifier,
                for: indexPath
            ) as? UnverifiedAssetCell {
                return cell
            }
        }
        
        if assetDetail.hasOnlyAssetName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UnverifiedOnlyNameAssetCell.reusableIdentifier,
                for: indexPath
            ) as? UnverifiedOnlyNameAssetCell {
                return cell
            }
        }
        
        if assetDetail.hasOnlyUnitName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UnverifiedOnlyUnitNameAssetCell.reusableIdentifier,
                for: indexPath
            ) as? UnverifiedOnlyUnitNameAssetCell {
                return cell
            }
        }
        
        if assetDetail.hasNoDisplayName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UnverifiedUnnamedAssetCell.reusableIdentifier,
                for: indexPath
            ) as? UnverifiedUnnamedAssetCell {
                return cell
            }
        }
        
        fatalError("Unexpected Element")
    }
}
