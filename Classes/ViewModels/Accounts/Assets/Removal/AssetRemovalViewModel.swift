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
        guard let assetName = asset.assetName,
            let code = asset.unitName else {
                return
        }
        
        cell.contextView.assetNameView.setName(assetName)
        cell.contextView.assetNameView.setCode(code)
        cell.contextView.actionButton.setTitle("title-remove-lowercased".localized, for: .normal)
    }
    
    func configure(_ header: AccountHeaderSupplementaryView, with account: Account) {
        header.contextView.setOptionsButton(hidden: true)
        
        guard let accountName = account.name else {
            return
        }
        
        header.contextView.setAccountName(accountName)
    }
}
