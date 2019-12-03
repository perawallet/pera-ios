//
//  AssetTransactionDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

struct AssetTransactionDraft: Codable {
    let fromAccount: Account
    var recipient: String?
    let amount: Double?
    let assetIndex: Int64?
    var assetCreator = ""
    var fee: Int64?
    var closeAssetsTo: String?
    var identifier: String?
}
