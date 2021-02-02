//
//  TransactionTrackDraft.swift

import Magpie

struct TransactionTrackDraft: JSONObjectBody {
    let transactionId: String
    
    var bodyParams: [BodyParam] {
        var params: [BodyParam] = []
        params.append(.init(.transactionId, transactionId))
        return params
    }
}
