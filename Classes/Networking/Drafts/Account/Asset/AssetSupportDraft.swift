//
//  AssetSupportDraft.swift

import Magpie

struct AssetSupportDraft: JSONObjectBody {
    let sender: String
    let receiver: String
    let assetId: Int64
    
    var bodyParams: [BodyParam] {
        var params: [BodyParam] = []
        params.append(.init(.sender, sender))
        params.append(.init(.receiver, receiver))
        params.append(.init(.asset, assetId))
        return params
    }
}
