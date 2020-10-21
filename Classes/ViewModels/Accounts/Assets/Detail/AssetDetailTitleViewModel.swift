//
//  AssetDetailTitleViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.10.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

class AssetDetailTitleViewModel {
    
    private(set) var detail: String?
    
    init(account: Account, assetDetail: AssetDetail?) {
        setDetail(from: assetDetail, in: account)
    }
    
    private func setDetail(from assetDetail: AssetDetail?, in account: Account) {
        if let assetDetail = assetDetail {
            guard let amount = account.amount(for: assetDetail) else {
                return
            }
            detail = "\(amount.toFractionStringForLabel(fraction: assetDetail.fractionDecimals) ?? "") \(assetDetail.getAssetCode())"
        } else {
            detail = "\(account.amount.toAlgos.toAlgosStringForLabel ?? "") ALGO"
        }
    }
}
