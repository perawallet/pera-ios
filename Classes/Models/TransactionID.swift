//
//  TransactionID.swift
//  algorand
//
//  Created by Omer Emre Aslan on 4.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct TransactionID: Model {
    let identifier: String
}

extension TransactionID {
    private enum CodingKeys: String, CodingKey {
        case identifier = "txId"
    }
}
