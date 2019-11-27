//
//  AssetFetchQuery.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct AssetFetchQuery: Query {
    typealias Key = RequestParameter
    
    let assetId: String
    let max: Int
    
    func decoded() -> [Pair]? {
        return [
            Pair(key: .assetId, value: .some(assetId)),
            Pair(key: .max, value: .some(max))
        ]
    }
}
