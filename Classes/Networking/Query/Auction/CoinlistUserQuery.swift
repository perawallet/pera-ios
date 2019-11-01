//
//  CoinlistUserQuery.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 3.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct CoinlistUserQuery: Query {
    typealias Key = RequestParameter
    
    let userId: String
    
    func decoded() -> [Pair]? {
        return [
            Pair(key: .username, value: .some(userId))
        ]
    }
}
