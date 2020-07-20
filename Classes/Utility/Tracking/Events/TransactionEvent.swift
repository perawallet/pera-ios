//
//  TransactionEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.07.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct TransactionEvent: TrackableEvent {
    private let algosEventId = "algos"
    
    let eventKey = "transaction"
    var parameters: [String: Any]? {
        return [
            "account_type": accountType.rawValue,
            "asset_id": assetId ?? algosEventId,
            "is_max": isMaxTransaction,
            "amount": amount ?? 0
        ]
    }
    
    let accountType: AccountType
    let assetId: String?
    let isMaxTransaction: Bool
    let amount: Int64?
}
