//
//  VerifiedAssetList.swift

import Magpie

class VerifiedAssetList: Model {
    let count: Int
    let next: String?
    let previous: String?
    let results: [VerifiedAsset]
}
