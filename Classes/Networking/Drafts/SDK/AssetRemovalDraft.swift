//
//  AssetRemovalDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 22.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct AssetRemovalDraft: TransactionsDraft {
    var from: String
    var transactionParams: TransactionParams
    let amount: Int64
    let assetCreatorAddress: String
    let assetIndex: Int64
}
