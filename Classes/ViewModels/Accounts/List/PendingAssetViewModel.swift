//
//  PendingAssetViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import Foundation

class PendingAssetViewModel {
    private(set) var assetDetail: AssetDetail?
    private(set) var detail: String?

    init(assetDetail: AssetDetail, isRemoving: Bool) {
        setAssetDetail(from: assetDetail)
        setDetail(from: isRemoving)
    }

    private func setAssetDetail(from assetDetail: AssetDetail) {
        self.assetDetail = assetDetail
    }

    private func setDetail(from isRemoving: Bool) {
        if isRemoving {
            detail = "asset-remove-confirmation-title".localized
        } else {
            detail = "asset-add-confirmation-title".localized
        }
    }
}
