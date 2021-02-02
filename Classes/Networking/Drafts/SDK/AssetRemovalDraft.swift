//
//  AssetRemovalDraft.swift

import Foundation

struct AssetRemovalDraft: TransactionDraft {
    var from: Account
    var transactionParams: TransactionParams
    let amount: Int64
    let assetCreatorAddress: String
    let assetIndex: Int64
}
