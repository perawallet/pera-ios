//
//  AssetTransactionRequestDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct AssetTransactionRequestDraft: Codable {
    let account: Account
    let amount: Double
    let assetDetail: AssetDetail
}
