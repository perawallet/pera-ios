//
//  AssetCardViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.10.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class AssetCardViewModel {
    
    private(set) var isVerified: Bool = false
    private(set) var name: String?
    private(set) var amount: String?
    private(set) var id: String?
    
    init(account: Account, assetDetail: AssetDetail) {
        setIsVerified(from: assetDetail)
        setName(from: assetDetail)
        setAmount(from: assetDetail, in: account)
        setId(from: assetDetail)
    }
    
    private func setIsVerified(from assetDetail: AssetDetail) {
        isVerified = assetDetail.isVerified
    }
    
    private func setName(from assetDetail: AssetDetail) {
        name = assetDetail.getDisplayNames().0
    }
    
    private func setAmount(from assetDetail: AssetDetail, in account: Account) {
        guard let assetAmount = account.amount(for: assetDetail) else {
            return
        }
        amount = assetAmount.toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
    }
    
    private func setId(from assetDetail: AssetDetail) {
        id = "asset-detail-id-title".localized(params: "\(assetDetail.id)")
    }
}
