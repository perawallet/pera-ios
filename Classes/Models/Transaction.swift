//
//  Transaction.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class Transaction: Mappable {

    let round: Int64?
    let id: TransactionID
    let fee: Int64
    let firstRound: Int64
    let noteb64: [Int64]?
    let from: String
    let payment: Payment?
    let lastRound: Int64
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        round = try container.decodeIfPresent(Int64.self, forKey: .round)
        
        let transactionId = try container.decode(String.self, forKey: .id)
        id = TransactionID(identifier: transactionId)
        
        fee = try container.decode(Int64.self, forKey: .fee)
        firstRound = try container.decode(Int64.self, forKey: .firstRound)
        noteb64 = try container.decodeIfPresent([Int64].self, forKey: .noteb64)
        from = try container.decode(String.self, forKey: .from)
        payment = try container.decodeIfPresent(Payment.self, forKey: .payment)
        lastRound = try container.decode(Int64.self, forKey: .lastRound)
    }
}

extension Transaction {
    
    enum CodingKeys: String, CodingKey {
        case round = "round"
        case id = "tx"
        case fee = "fee"
        case firstRound = "first-round"
        case noteb64 = "noteb64"
        case from = "from"
        case payment = "payment"
        case lastRound = "last-round"
    }
}
