//
//  VerifiedAsset.swift

import Magpie

class VerifiedAsset: Model {
    let id: Int64
}

extension VerifiedAsset {
    enum CodingKeys: String, CodingKey {
        case id = "asset_id"
    }
}

extension VerifiedAsset: Equatable {
    static func == (lhs: VerifiedAsset, rhs: VerifiedAsset) -> Bool {
        return lhs.id == rhs.id
    }
}
