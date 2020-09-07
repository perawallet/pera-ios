//
//  AssetSupportDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct AssetSupportDraft: JSONKeyedBody {
    typealias Key = RequestParameter
    
    let sender: String
    let receiver: String
    let assetId: Int64
    
    func decoded() -> [Pair]? {
        return [
            Pair(key: .sender, value: sender),
            Pair(key: .receiver, value: receiver),
            Pair(key: .asset, value: assetId)
        ]
    }
}
