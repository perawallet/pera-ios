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
    
    let limit: Int
    
    func decoded() -> [Pair]? {
        return [Pair(key: .limit, value: .some(limit))]
    }
}
