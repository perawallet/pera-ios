//
//  PendingTransactions.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct PendingTransactions: Model {
    var transactions: [Transaction]?
}
