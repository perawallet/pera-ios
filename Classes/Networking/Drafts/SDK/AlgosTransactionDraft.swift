//
//  AlgosTransactionDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 22.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct AlgosTransactionDraft: TransactionDraft {
    var from: Account
    let toAccount: String
    var transactionParams: TransactionParams
    let amount: Int64
    let isMaxTransaction: Bool
}
