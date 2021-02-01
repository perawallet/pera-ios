//
//  AssetFreezeTransaction.swift

import Magpie

class AssetFreezeTransaction: Model {
    let address: String?
    let isFreeze: Bool?
    let assetId: Int64?
}

extension AssetFreezeTransaction {
    private enum CodingKeys: String, CodingKey {
        case address = "address"
        case isFreeze = "new-freeze-status"
        case assetId = "asset-id"
    }
}
