//
//  AssetRemovalViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 24.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetRemovalViewModel {    
    func configure(_ cell: BaseAssetCell, with asset: AssetDetail) {
        cell.contextView.assetNameView.setAssetName(for: asset)
        cell.contextView.setActionText("title-remove".localized)
        cell.contextView.setActionFont(UIFont.font(withWeight: .semiBold(size: 14.0)))
        cell.contextView.setActionColor(SharedColors.red)
    }
    
    func configure(_ header: AccountHeaderSupplementaryView, with account: Account) {
        header.contextView.setOptionsButton(hidden: true)
        header.contextView.setQRButton(hidden: true)
        
        if account.isLedger() {
            header.contextView.setLedgerAccount()
        } else if account.isRekeyed() {
            header.contextView.setRekeyedAccount()
        } else {
            header.contextView.setStandardAccount()
        }
        
        guard let accountName = account.name else {
            return
        }
        
        header.contextView.setAccountName(accountName)
    }
}
