//
//  LedgerTransactionSigner.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import Foundation

class LedgerTransactionSigner: TransactionSigner {

    private var account: Account

    init(account: Account) {
        self.account = account
        super.init()
    }

    override func sign(_ data: Data?, with privateData: Data?) -> Data? {
        return signTransaction(data, with: privateData)
    }
}

extension LedgerTransactionSigner {
    private func signTransaction(_ data: Data?, with privateData: Data?) -> Data? {
        var transactionError: NSError?

        guard let transactionData = data,
              let privateData = privateData else {
            delegate?.transactionSigner(self, didFailedSigning: .inapp(TransactionError.sdkError(error: transactionError)))
            return nil
        }

        if account.isRekeyed() {
            return signRekeyedAccountTransaction(transactionData, with: privateData, transactionError: &transactionError)
        } else {
            return signLedgerAccountTransaction(transactionData, with: privateData, transactionError: &transactionError)
        }
    }

    private func signRekeyedAccountTransaction(_ transactionData: Data, with privateData: Data, transactionError: inout NSError?) -> Data? {
        guard let signedTransactionData = algorandSDK.getSignedTransaction(
            with: account.authAddress,
            transaction: transactionData,
            from: privateData,
            error: &transactionError
        ) else {
            delegate?.transactionSigner(self, didFailedSigning: .inapp(TransactionError.sdkError(error: transactionError)))
            return nil
        }

        return signedTransactionData
    }

    private func signLedgerAccountTransaction(_ transactionData: Data, with privateData: Data, transactionError: inout NSError?) -> Data? {
        guard let signedTransactionData = algorandSDK.getSignedTransaction(
            transactionData,
            from: privateData,
            error: &transactionError
        ) else {
            delegate?.transactionSigner(self, didFailedSigning: .inapp(TransactionError.sdkError(error: transactionError)))
            return nil
        }

        return signedTransactionData
    }
}
