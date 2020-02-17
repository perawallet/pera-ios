//
//  AssetAdditionDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 22.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct AssetAdditionDraft: TransactionDraft {
    var from: Account
    var transactionParams: TransactionParams
    let assetIndex: Int64
}
