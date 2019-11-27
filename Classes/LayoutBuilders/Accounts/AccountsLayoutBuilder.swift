//
//  AccountsLayoutBuilder.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AccountsLayoutBuilderDelegate: class {
    func accountsLayoutBuilder(_ layoutBuilder: AccountsLayoutBuilder, didSelectAt indexPath: IndexPath)
}

class AccountsLayoutBuilder: NSObject, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: AccountsLayoutBuilderDelegate?
    
    private let layout = Layout<LayoutConstants>()
}

extension AccountsLayoutBuilder {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.accountsLayoutBuilder(self, didSelectAt: indexPath)
    }
}

extension AccountsLayoutBuilder {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return layout.current.cellSpacing
    }
}

extension AccountsLayoutBuilder {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(
            width: UIScreen.main.bounds.width - layout.current.defaultSectionInsets.left - layout.current.defaultSectionInsets.right,
            height: layout.current.cellHeight
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: layout.current.headerHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: layout.current.footerHeight)
    }
}

extension AccountsLayoutBuilder {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let firstSectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        let defaultSectionInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
        let cellSpacing: CGFloat = 5.0
        let cellHeight: CGFloat = 50.0
        let footerHeight: CGFloat = 39.0
        let headerHeight: CGFloat = 45.0
    }
}
