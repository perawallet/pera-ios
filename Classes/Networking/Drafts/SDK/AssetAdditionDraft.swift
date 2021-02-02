//
//  AssetAdditionDraft.swift

import Foundation

struct AssetAdditionDraft: TransactionDraft {
    var from: Account
    var transactionParams: TransactionParams
    let assetIndex: Int64
}
