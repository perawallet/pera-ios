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
    
    let query: String?
    let limit: Int
    let offset: Int
    
    func decoded() -> [Pair]? {
        var pairs = [Pair(key: .limit, value: .some(limit)), Pair(key: .offset, value: .some(offset))]
        if let query = query {
            pairs.append(Pair(key: .query, value: .some(query)))
        }
        return pairs
    }
}
