//
//  Payment.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class Payment: Model {
    let amount: Int64
    let toAddress: String
    let rewards: UInt64?
    let closeAmount: Int64?
    let closeAddress: String?
    let closeRewards: Int64?
    
    func amountForTransaction(includesCloseAmount: Bool) -> Int64 {
        if let closeAmount = closeAmount, closeAmount != 0, includesCloseAmount {
            return closeAmount + amount
        }
        return amount
    }
    
    func closeAmountForTransaction() -> Int64? {
        guard let closeAmount = closeAmount, closeAmount != 0 else {
            return nil
        }
        
        return closeAmount
    }
}

extension Payment {
    private enum CodingKeys: String, CodingKey {
        case amount = "amount"
        case toAddress = "to"
        case rewards = "torewards"
        case closeAmount = "closeamount"
        case closeAddress = "close"
        case closeRewards = "closerewards"
    }
}
