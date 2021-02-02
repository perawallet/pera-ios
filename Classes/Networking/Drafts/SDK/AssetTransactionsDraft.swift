//
//  AssetTransactionDraft.swift

import Foundation

struct AssetTransactionDraft: TransactionDraft {
    var from: Account
    let toAccount: String
    var transactionParams: TransactionParams
    let amount: Int64
    let assetIndex: Int64
    var note: Data?
}
