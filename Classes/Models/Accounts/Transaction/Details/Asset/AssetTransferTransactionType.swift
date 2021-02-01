//
//  AssetTransferTransaction.swift

import Magpie

class AssetTransferTransaction: Model {
    let amount: Int64
    let closeAmount: Int64?
    let closeToAddress: String?
    let assetId: Int64
    let receiverAddress: String?
    let senderAddress: String?
}

extension AssetTransferTransaction {
    private enum CodingKeys: String, CodingKey {
        case amount = "amount"
        case closeAmount = "close-amount"
        case closeToAddress = "close-to"
        case assetId = "asset-id"
        case receiverAddress = "receiver"
        case senderAddress = "sender"
    }
}
