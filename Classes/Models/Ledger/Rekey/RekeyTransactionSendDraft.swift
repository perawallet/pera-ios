//
//  RekeyTransactionSendDraft.swift

import Foundation

struct RekeyTransactionSendDraft: TransactionSendDraft {
    var from: Account
    var toAccount: String?
    var amount: Double?
    var fee: Int64?
    var isMaxTransaction = false
    var identifier: String?
    var note: String?
    
    init(account: Account, rekeyedTo: String) {
        self.from = account
        toAccount = rekeyedTo
        amount = nil
        fee = nil
        isMaxTransaction = false
        identifier = nil
    }
}
