//
//  AlgosTransactionDraft.swift

import Foundation

struct AlgosTransactionDraft: TransactionDraft {
    var from: Account
    let toAccount: String
    var transactionParams: TransactionParams
    let amount: Int64
    let isMaxTransaction: Bool
    var note: Data?
}
