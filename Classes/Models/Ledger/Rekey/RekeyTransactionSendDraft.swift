//
//  RekeyTransactionSendDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct RekeyTransactionSendDraft: TransactionSendDraft {
    var from: Account
    var toAccount: String?
    var amount: Double?
    var fee: Int64?
    var isMaxTransaction = false
    var identifier: String?
    
    init(account: Account, rekeyedTo: String) {
        self.from = account
        toAccount = rekeyedTo
        amount = nil
        fee = nil
        isMaxTransaction = false
        identifier = nil
    }
}
