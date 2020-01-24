//
//  AssetTransferTransactionType.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 2.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class AssetTransferTransactionType: Model {
    let amount: Int64
    let closeToAddress: String?
    let assetId: Int64
    let receiverAddress: String?
    let senderAddress: String?
}

extension AssetTransferTransactionType {
    private enum CodingKeys: String, CodingKey {
        case amount = "amt"
        case closeToAddress = "closeto"
        case assetId = "id"
        case receiverAddress = "rcv"
        case senderAddress = "snd"
    }
}
