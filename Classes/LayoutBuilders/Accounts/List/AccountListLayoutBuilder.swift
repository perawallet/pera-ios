//
//  AccountListLayoutBuilder.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AccountListLayoutBuilderDelegate: class {
    func accountListLayoutBuilder(_ layoutBuilder: AccountListLayoutBuilder, didSelectAt indexPath: IndexPath)
}

class AccountListLayoutBuilder: NSObject, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: AccountListLayoutBuilderDelegate?
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width, height: 50.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.cellForItem(at: indexPath) is AccountViewCell {
            delegate?.accountListLayoutBuilder(self, didSelectAt: indexPath)
        }
    }
}
