//
//  LedgerAccountAssetCountViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

class LedgerAccountAssetCountViewModel {
    
    private(set) var assetCount: String?
    
    init(account: Account) {
        setAssetCount(from: account)
    }
    
    private func setAssetCount(from account: Account) {
        guard let assets = account.assets,
              !assets.isEmpty else {
            return
        }
        
        assetCount = "title-plus-asset-count".localized
    }
}
