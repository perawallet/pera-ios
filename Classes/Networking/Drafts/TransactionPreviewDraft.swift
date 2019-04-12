//
//  TransactionPreviewDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

struct TransactionPreviewDraft: Codable {
    let fromAccount: Account
    let amount: Double
    var identifier: String?
    var fee: Int64?
}
