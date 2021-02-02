//
//  RekeyTransactionDraft.swift

import Foundation

struct RekeyTransactionDraft: TransactionDraft {
    var from: Account
    let rekeyedAccount: String
    var transactionParams: TransactionParams
}
