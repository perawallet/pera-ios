//
//  CoinlistTransaction.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

enum DepositActionType: String, Model {
    case deposit = "deposit"
    case withdrawal = "withdrawal"
}

enum DepositStatus: String, Model {
    case pending = "pending"
    case completed = "completed"
}

class CoinlistTransaction: Model {
    let type: DepositActionType?
    let amount: Int?
    let time: String?
    let username: String?
    let description: String?
    let status: DepositStatus?
    
    var balanceAfterTransaction: Int?
}

extension CoinlistTransaction {
    private enum CodingKeys: String, CodingKey {
        case type = "type"
        case amount = "amount"
        case time = "time"
        case username = "username"
        case description = "description"
        case status = "status"
    }
}
