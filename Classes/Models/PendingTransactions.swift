//
//  PendingTransactions.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class PendingTransactions: Model {
    var transactions: [Transaction]
    var count: Int
}

extension PendingTransactions {
    private enum CodingKeys: String, CodingKey {
        case transactions = "truncatedTxns"
        case count = "totalTxns"
    }
}
