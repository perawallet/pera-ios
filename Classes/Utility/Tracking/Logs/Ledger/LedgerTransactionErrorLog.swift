//
//  LedgerTransactionErrorLog.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 4.11.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct LedgerTransactionErrorLog: AnalyticsLog {
    var name: AnalyticsLogName = .ledgerTransactionError
    var params: AnalyticsParameters
    
    init(account: Account, transactionData: TransactionData) {
        params = [
            .sender: account.address,
            .unsignedTransaction: transactionData.unsignedTransaction?.base64EncodedString() ?? "",
            .signedTransaction: transactionData.signedTransaction?.base64EncodedString() ?? ""
        ]
    }
}
