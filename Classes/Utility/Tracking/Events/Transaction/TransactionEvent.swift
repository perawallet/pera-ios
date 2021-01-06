//
//  TransactionEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.07.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct TransactionEvent: AnalyticsEvent {
    let accountType: AccountType
    let assetId: String?
    let isMaxTransaction: Bool
    let amount: Int64?
    
    private let algosEventId = "algos"
    
    let key: AnalyticsEventKey = .transaction
    
    var params: AnalyticsParameters? {
        return [.accountType: accountType.rawValue, .assetId: assetId ?? algosEventId, .isMax: isMaxTransaction, .amount: amount ?? 0]
    }
}
