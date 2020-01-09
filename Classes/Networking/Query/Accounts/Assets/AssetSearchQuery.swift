//
//  AssetFetchQuery.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct AssetSearchQuery: Query {
    typealias Key = RequestParameter
    
    let query: String
    
    func decoded() -> [Pair]? {
        return [Pair(key: .query, value: .some(query))]
    }
}
