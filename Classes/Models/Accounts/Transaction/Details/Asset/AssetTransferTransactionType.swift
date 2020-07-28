//
//  AssetTransferTransaction.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 2.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

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
