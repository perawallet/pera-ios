//
//  TransactionEvent.swift

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
