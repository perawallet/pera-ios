//
//  TransactionTrackDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct TransactionTrackDraft: JSONObjectBody {
    let transactionId: String
    
    var bodyParams: [BodyParam] {
        var params: [BodyParam] = []
        params.append(.init(.transactionId, transactionId))
        return params
    }
}
