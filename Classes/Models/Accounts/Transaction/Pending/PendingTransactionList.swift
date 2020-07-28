//
//  PendingTransactionList.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class PendingTransactionList: Model {
    var pendingTransactions: [PendingTransaction]
    var count: Int
}

extension PendingTransactionList {
    private enum CodingKeys: String, CodingKey {
        case pendingTransactions = "top-transactions"
        case count = "total-transactions"
    }
}
