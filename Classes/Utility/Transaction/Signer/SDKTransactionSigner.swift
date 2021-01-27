//
//  SDKTransactionSigner.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import Foundation

class SDKTransactionSigner: TransactionSigner {

    override func sign(_ data: Data?, with privateData: Data?) -> Data? {
        return signTransaction(data, with: privateData)
    }
}

extension SDKTransactionSigner {
    private func signTransaction(_ data: Data?, with privateData: Data?) -> Data? {
        var transactionError: NSError?

        guard let unsignedTransactionData = data,
              let privateData = privateData,
              let signedTransactionData = algorandSDK.sign(
                privateData,
                with: unsignedTransactionData,
                error: &transactionError
              ) else {
            delegate?.transactionSigner(self, didFailedSigning: .inapp(TransactionError.sdkError(error: transactionError)))
            return nil
        }

        return signedTransactionData
    }
}
