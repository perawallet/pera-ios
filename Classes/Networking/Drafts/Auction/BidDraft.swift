//
//  BidDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 3.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct BidDraft: JSONBody {
    typealias Key = RequestParameter
    
    let bidData: String
    
    func decoded() -> [Pair]? {
        return [
            Pair(key: .bid, value: bidData)
        ]
    }
}
