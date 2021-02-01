//
//  AssetTransactionDisplayDraft.swift

import Foundation

struct AssetTransactionSendDraft: TransactionSendDraft {
    var from: Account
    var toAccount: String?
    var amount: Double?
    var fee: Int64?
    var isMaxTransaction = false
    var identifier: String?
    let assetIndex: Int64?
    var assetCreator = ""
    var closeAssetsTo: String?
    var assetDecimalFraction = 0
    var isVerifiedAsset = false
    var note: String?
}
