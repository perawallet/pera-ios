//
//  AssetRemovalViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 24.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetRemovalViewModel {    
    func configure(_ cell: AssetActionableCell, with asset: AssetDetail) {
        cell.contextView.assetNameView.setAssetName(for: asset)
        cell.contextView.actionButton.setTitle("title-remove".localized, for: .normal)
    }
    
    func configure(_ header: AccountHeaderSupplementaryView, with account: Account) {
        header.contextView.setOptionsButton(hidden: true)
        header.contextView.setQRButton(hidden: true)
        
        if account.type == .ledger {
            header.contextView.setLedgerAccount()
        } else {
            header.contextView.setStandardAccount()
        }
        
        guard let accountName = account.name else {
            return
        }
        
        header.contextView.setAccountName(accountName)
    }
}
