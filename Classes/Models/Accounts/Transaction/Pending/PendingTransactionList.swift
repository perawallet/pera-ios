//
//  PendingTransactionList.swift

import Magpie

class PendingTransactionList: Model {
    var pendingTransactions: [PendingTransaction]
    var count: Int
}

extension PendingTransactionList {
    private enum CodingKeys: String, CodingKey {
        case pendingTransactions = "top-transactions"
        case count = "total-transactions"
    }
}
