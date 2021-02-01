//
//  LedgerTransactionErrorLog.swift

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
