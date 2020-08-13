//
//  RekeyTransactionDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct RekeyTransactionDraft: TransactionDraft {
    var from: Account
    let rekeyedAccount: String
    var transactionParams: TransactionParams
}
