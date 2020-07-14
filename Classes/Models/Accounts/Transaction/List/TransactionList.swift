//
//  TransactionList.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class TransactionList: Model {
    let currentRound: Int64
    let nextToken: String?
    let transactions: [Transaction]
}

extension TransactionList {
    enum CodingKeys: String, CodingKey {
        case currentRound = "current-round"
        case nextToken = "next-token"
        case transactions = "transactions"
    }
}
