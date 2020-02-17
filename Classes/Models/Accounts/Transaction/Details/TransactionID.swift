//
//  TransactionID.swift
//  algorand
//
//  Created by Omer Emre Aslan on 4.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class TransactionID: Model {
    let identifier: String
    
    init(identifier: String) {
        self.identifier = identifier
    }
}

extension TransactionID {
    private enum CodingKeys: String, CodingKey {
        case identifier = "txId"
    }
}
