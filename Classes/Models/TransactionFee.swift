//
//  TransactionFee.swift
//  algorand
//
//  Created by Omer Emre Aslan on 4.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct TransactionParams: Mappable {
    private let roundDifference = 1000
    
    let fee: Int64
    let firstRound: Int64
    let lastRound: Int64
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        fee = try container.decode(Int64.self, forKey: .fee)
        firstRound = try container.decode(Int64.self, forKey: .lastRound)
        lastRound = firstRound + Int64(roundDifference)
    }
    
    private enum CodingKeys: String, CodingKey {
        case lastRound = "lastRound"
        case fee = "fee"
    }
}
