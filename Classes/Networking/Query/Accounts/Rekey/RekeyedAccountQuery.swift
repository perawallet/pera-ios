//
//  RekeyedAccountQuery.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

struct RekeyedAccountQuery: Query {
    typealias Key = RequestParameter
    
    let authAddress: String
    
    func decoded() -> [Pair]? {
        return [
            Pair(key: .authAddress, value: .some(authAddress))
        ]
    }
}
