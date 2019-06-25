//
//  BlockchainInsturction.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class BlockchainInstruction: Mappable {
    
    let address: String?
    let rate: Int?
    let time: Int?
}

extension BlockchainInstruction {
    
    enum CodingKeys: String, CodingKey {
        case address = "address"
        case rate = "rate"
        case time = "time"
    }
}
