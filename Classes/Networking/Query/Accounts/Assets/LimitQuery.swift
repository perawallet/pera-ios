//
//  VerifiedAssetQuery.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 6.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

struct LimitQuery: Query {
    typealias Key = RequestParameter
    
    var limit = "all"
    
    func decoded() -> [Pair]? {
        return [Pair(key: .limit, value: .some(limit))]
    }
}
