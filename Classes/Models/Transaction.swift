//
//  Transaction.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class Transaction: Model {

    enum Constant {
        static let minimumFee: Int64 = 1000
    }
    
    let round: Int64?
    let id: TransactionID
    let fee: Int64
    let firstRound: Int64
    let noteb64: String?
    let from: String
    let payment: Payment?
    let lastRound: Int64
    let type: String
    let fromRewards: UInt64?
    
    var contact: Contact?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        round = try container.decodeIfPresent(Int64.self, forKey: .round)
        
        let transactionId = try container.decode(String.self, forKey: .id)
        id = TransactionID(identifier: transactionId)
        
        fee = try container.decode(Int64.self, forKey: .fee)
        firstRound = try container.decode(Int64.self, forKey: .firstRound)
        noteb64 = try container.decodeIfPresent(String.self, forKey: .noteb64)
        from = try container.decode(String.self, forKey: .from)
        payment = try container.decodeIfPresent(Payment.self, forKey: .payment)
        lastRound = try container.decode(Int64.self, forKey: .lastRound)
        type = try container.decode(String.self, forKey: .type)
        fromRewards = try container.decodeIfPresent(UInt64.self, forKey: .fromRewards)
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
        case type = "type"
        case fromRewards = "fromrewards"
    }
}
