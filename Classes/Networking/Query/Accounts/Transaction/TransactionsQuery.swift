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
    
    let max: Int
    let from: String?
    let to: String?
    
    func decoded() -> [Pair]? {
        var pairs = [Pair(key: .max, value: .some(max))]
        if let from = from,
            let to = to {
            pairs.append(contentsOf: [Pair(key: .from, value: .some(from)), Pair(key: .to, value: .some(to))])
        }
        
        return pairs
    }
}
