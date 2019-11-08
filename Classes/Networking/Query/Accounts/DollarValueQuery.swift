//
//  DollarValueQuery.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 3.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct DollarValueQuery: Query {
    typealias Key = RequestParameter
    
    func decoded() -> [Pair]? {
        return [
            Pair(key: .algoDollarConversion, value: .some("ALGOUSDT"))
        ]
    }
}
