//
//  AssetSupportDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

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
