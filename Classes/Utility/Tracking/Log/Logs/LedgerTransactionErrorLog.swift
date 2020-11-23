//
//  LedgerTransactionErrorLog.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 4.11.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct LedgerTransactionErrorLog: ErrorLog {
    let name: ErrorLogs = .ledgerTransactionError
    var params: [ErrorLogParamKeys: Any]
    
    init(account: Account, unsignedTransaction: Data?, signedTransaction: Data?) {
        params = [
            .sender: account.address,
            .unsignedTransaction: unsignedTransaction?.base64EncodedString() ?? "",
            .signedTransaction: signedTransaction?.base64EncodedString() ?? ""
        ]
    }
}
