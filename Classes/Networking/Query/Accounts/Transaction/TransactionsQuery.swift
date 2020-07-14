//
//  TransactionsQuery.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 3.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct TransactionsQuery: Query {
    typealias Key = RequestParameter
    
    let limit: Int?
    let from: String?
    let to: String?
    let next: String?
    let assetId: String?
    
    func decoded() -> [Pair]? {
        var pairs = [Pair]()
        
        if let limit = limit {
            pairs.append(Pair(key: .limit, value: .some(limit)))
        }
        
        if let from = from,
            let to = to {
            pairs.append(contentsOf: [Pair(key: .afterTime, value: .some(from)), Pair(key: .beforeTime, value: .some(to))])
        }
        
        if let next = next {
            pairs.append(Pair(key: .next, value: .some(next)))
        }
        
        if let assetId = assetId {
            pairs.append(Pair(key: .assetIdFilter, value: .some(assetId)))
        }
        
        return pairs
    }
}
