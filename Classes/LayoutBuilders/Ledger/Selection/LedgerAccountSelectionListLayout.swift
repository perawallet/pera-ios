//
//  LedgerAccountSelectionListLayout.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerAccountSelectionListLayout: NSObject {
    
    weak var delegate: LedgerAccountSelectionListLayoutDelegate?
    private weak var dataSource: LedgerAccountSelectionDataSource?
    
    init(dataSource: LedgerAccountSelectionDataSource) {
        self.dataSource = dataSource
        super.init()
    }
}

extension LedgerAccountSelectionListLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        var height: CGFloat = 0.0
        let headerHeight: CGFloat = 64.0
        let algosHeight: CGFloat = 54.0
        let multiAssetNameHeight: CGFloat = 72.0
        let singleAssetNameHeight: CGFloat = 52.0
        let rekeyInfoHeight: CGFloat = 68.0
        height += headerHeight + algosHeight
        
        if let account = dataSource?.account(at: indexPath.item) {
            for assetDetail in account.assetDetails {
                if assetDetail.hasBothDisplayName() {
                    height += multiAssetNameHeight
                } else {
                    height += singleAssetNameHeight
                }
            }
            
            if dataSource?.shouldSetDisabled(at: indexPath) ?? false {
                height += rekeyInfoHeight
            }
        }
        
        return CGSize(width: UIScreen.main.bounds.width, height: height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return LedgerAccountSelectionHeaderSupplementaryView.calculatePreferredSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return !(dataSource?.shouldSetDisabled(at: indexPath) ?? false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? AccountSelectionCell
        cell?.contextView.state = .selected
        delegate?.ledgerAccountSelectionListLayout(self, didSelectAccountAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? AccountSelectionCell
        cell?.contextView.state = .unselected
        delegate?.ledgerAccountSelectionListLayout(self, didDeselectAccountAt: indexPath)
    }
}

protocol LedgerAccountSelectionListLayoutDelegate: class {
    func ledgerAccountSelectionListLayout(
        _ listLayout: LedgerAccountSelectionListLayout,
        didSelectAccountAt indexPath: IndexPath
    )
    func ledgerAccountSelectionListLayout(
        _ listLayout: LedgerAccountSelectionListLayout,
        didDeselectAccountAt indexPath: IndexPath
    )
}
