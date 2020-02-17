//
//  AssetTransactionDisplayDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

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
}
