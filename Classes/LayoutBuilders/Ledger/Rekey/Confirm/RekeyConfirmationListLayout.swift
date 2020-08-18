//
//  RekeyConfirmationListLayout.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 5.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class RekeyConfirmationListLayout: NSObject {
    
    private let layout = Layout<LayoutConstants>()
    
    private var shouldDisplayFooter = true
    
    private let account: Account
    
    init(account: Account) {
        self.account = account
        super.init()
    }
}

extension RekeyConfirmationListLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = UIScreen.main.bounds.width - layout.current.defaultSectionInsets.left - layout.current.defaultSectionInsets.right
        if indexPath.item == 0 {
            return CGSize(width: width, height: layout.current.itemHeight)
        } else {
            if account.assetDetails[indexPath.item - 1].hasBothDisplayName() {
                return CGSize(width: width, height: layout.current.multiItemHeight)
            } else {
                return CGSize(width: width, height: layout.current.itemHeight)
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(
            width: UIScreen.main.bounds.width - layout.current.defaultSectionInsets.left - layout.current.defaultSectionInsets.right,
            height: layout.current.itemHeight
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        if !shouldDisplayFooter {
            return .zero
        }
        return CGSize(
            width: UIScreen.main.bounds.width - layout.current.defaultSectionInsets.left - layout.current.defaultSectionInsets.right,
            height: layout.current.footerHeight
        )
    }
}

extension RekeyConfirmationListLayout {
    func setFooterHidden(_ isHidden: Bool) {
        shouldDisplayFooter = !isHidden
    }
}

extension RekeyConfirmationListLayout {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultSectionInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        let itemHeight: CGFloat = 52.0
        let footerHeight: CGFloat = 45.0
        let multiItemHeight: CGFloat = 72.0
    }
}
