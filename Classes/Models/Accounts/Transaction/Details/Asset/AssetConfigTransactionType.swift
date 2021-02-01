//
//  AssetConfigTransaction.swift

import Magpie

class AssetConfigTransaction: Model {
    let id: Int64?
}

extension AssetConfigTransaction {
    private enum CodingKeys: String, CodingKey {
        case id = "asset-id"
    }
}
