//
//  CursorQuery.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 20.07.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

struct CursorQuery: Query {
    typealias Key = RequestParameter
    
    let cursor: String?
    
    func decoded() -> [Pair]? {
        var pairs = [Pair]()
        
        if let cursor = cursor {
            pairs.append(Pair(key: .cursor, value: .some(cursor)))
        }
        
        return pairs
    }
}
