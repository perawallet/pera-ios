//
//  TransactionDraft.swift
//  algorand
//
//  Created by Omer Emre Aslan on 4.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

struct TransactionDraft {
    let from: Account
    let to: Account
    let amount: Int64
    let transactionParams: TransactionParams
}
