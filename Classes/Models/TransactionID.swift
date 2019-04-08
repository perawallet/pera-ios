//
//  TransactionID.swift
//  algorand
//
//  Created by Omer Emre Aslan on 4.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct TransactionID: Mappable {
    let identifier: String
    
    enum CodingKeys: String, CodingKey {
        case identifier = "txId"
    }
}
