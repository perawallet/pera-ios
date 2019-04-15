//
//  Payment.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class Payment: Mappable {
    
    let amount: Int64
    let toAddress: String
    
    enum CodingKeys: String, CodingKey {
        case amount = "amount"
        case toAddress = "to"
    }
}
