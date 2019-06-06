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
        
        return CGSize(width: (UIScreen.main.bounds.width - 26.0) / 3, height: 267.0 * verticalScale / 4.0)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        
        return 0.0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? NumpadNumericCell {
            delegate?.numpadViewLayoutBuilder(self, didSelect: cell.contextView.value)
            
            cell.contextView.color = SharedColors.purple
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                cell.contextView.color = rgba(0.04, 0.05, 0.07, 0.8)
            }
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? NumpadDeleteCell {
            delegate?.numpadViewLayoutBuilder(self, didSelect: cell.contextView.value)
        }
    }
}
