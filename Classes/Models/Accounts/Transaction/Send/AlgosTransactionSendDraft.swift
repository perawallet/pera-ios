//
//  AlgosTransactionDisplayDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

struct AlgosTransactionSendDraft: TransactionSendDraft {
    var from: Account
    var toAccount: String?
    var amount: Double?
    var fee: Int64?
    var isMaxTransaction = false
    var identifier: String?
    var note: String?
}
