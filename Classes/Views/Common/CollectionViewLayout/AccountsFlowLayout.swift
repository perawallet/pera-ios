//
//  AccountsFlowLayout.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 16.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountsFlowLayout: UICollectionViewFlowLayout {
    
    private enum Constants {
        static let tabBarHeight: CGFloat = 48.0
    }
    
    override var collectionViewContentSize: CGSize {
        let size = super.collectionViewContentSize
        
        guard size.height != 0.0,
            let view = collectionView?.superview else {
            return size
        }
        
        if size.height > view.frame.height - AccountsView.LayoutConstants.headerHeight - Constants.tabBarHeight - view.safeAreaBottom {
            return CGSize(width: size.width, height: size.height + AccountsView.LayoutConstants.headerHeight)
        }
        
        return size
    }
}
