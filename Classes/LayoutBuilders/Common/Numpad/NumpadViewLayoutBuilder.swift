//
//  NumpadViewLayoutBuilder.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol NumpadViewLayoutBuilderDelegate: class {
    
    func numpadViewLayoutBuilder(_ layoutBuilder: NumpadViewLayoutBuilder, didSelect value: NumpadValue)
}

class NumpadViewLayoutBuilder: NSObject, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: NumpadViewLayoutBuilderDelegate?
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        return CGSize(width: 30.0, height: 36.0)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        
        return 36.0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        
        return 86.5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? NumpadNumericCell {
            delegate?.numpadViewLayoutBuilder(self, didSelect: cell.contextView.value)
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? NumpadDeleteCell {
            delegate?.numpadViewLayoutBuilder(self, didSelect: cell.contextView.value)
        }
    }
}
