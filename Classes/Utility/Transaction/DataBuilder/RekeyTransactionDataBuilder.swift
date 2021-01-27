//
//  RekeyTransactionDataBuilder.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import Foundation

class RekeyTransactionDataBuilder: TransactionDataBuilder {

    override func composeData() -> Data? {
        return composeRekeyTransactionData()
    }

    private func composeRekeyTransactionData() -> Data? {
        guard let params = params,
              let rekeyTransactionSendDraft = draft as? RekeyTransactionSendDraft,
              let rekeyedAccount = rekeyTransactionSendDraft.toAccount else {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.draft(draft: draft)))
            return nil
        }

        var transactionError: NSError?
        let rekeyTransactionDraft = RekeyTransactionDraft(
            from: rekeyTransactionSendDraft.from,
            rekeyedAccount: rekeyedAccount,
            transactionParams: params
        )

        guard let transactionData = algorandSDK.rekeyAccount(with: rekeyTransactionDraft, error: &transactionError) else {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.sdkError(error: transactionError)))
            return nil
        }

        return transactionData
    }
}
