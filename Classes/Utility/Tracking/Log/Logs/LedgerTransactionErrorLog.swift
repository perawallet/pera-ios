//
//  LedgerTransactionErrorLog.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 4.11.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct LedgerTransactionErrorLog: ErrorLog {
    var id: Int {
        return 1
    }
    
    var name: String {
        return "LedgerTransactionError"
    }

    var params: [String: String] {
        return [
            "sender": sender,
            "unsigned_transaction": unsignedTransaction ?? "",
            "signed_transaction": unsignedTransaction ?? ""
        ]
    }
    
    let sender: String
    let unsignedTransaction: String?
    let signedTransaction: String?
}
