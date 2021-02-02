//
//  AssetViewModel.swift

import UIKit

class AssetViewModel {
    private(set) var assetDetail: AssetDetail?
    private(set) var amount: String?

    init(assetDetail: AssetDetail, asset: Asset) {
        setAssetDetail(from: assetDetail)
        setAmount(from: assetDetail, with: asset)
    }

    private func setAssetDetail(from assetDetail: AssetDetail) {
        self.assetDetail = assetDetail
    }

    private func setAmount(from assetDetail: AssetDetail, with asset: Asset) {
        amount = asset.amount.assetAmount(fromFraction: assetDetail.fractionDecimals)
            .toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
    }
}
