//
//  TransactionFetchDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 9.07.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct TransactionFetchDraft {
    let account: Account
    let dates: (from: Date?, to: Date?)
    let nextToken: String?
    let assetId: String?
    let limit: Int?
}
