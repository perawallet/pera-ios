//
//  TransactionTrackDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct TransactionTrackDraft: JSONBody {
    typealias Key = RequestParameter
    
    let transactionId: String
    
    func decoded() -> [Pair]? {
        return [
            Pair(key: .transactionId, value: transactionId)
        ]
    }
}
