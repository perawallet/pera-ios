//
//  CoinlistTransaction.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class CoinlistTransaction: Mappable {
    
    let type: String
    let amount: String
    let time: String
    let username: String
    let description: String
}

extension CoinlistTransaction {
    
    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case amount = "Amount"
        case time = "time"
        case username = "username"
        case description = "Description"
    }
}
