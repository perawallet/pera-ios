//
//  AlgosTransactionDisplayDraft.swift

import Foundation

struct AlgosTransactionSendDraft: TransactionSendDraft {
    var from: Account
    var toAccount: String?
    var amount: Double?
    var fee: Int64?
    var isMaxTransaction = false
    var identifier: String?
    var note: String?
}
