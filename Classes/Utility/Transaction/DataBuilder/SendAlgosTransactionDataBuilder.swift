//
//  SendAlgosTransactionDataBuilder.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import Foundation

class SendAlgosTransactionDataBuilder: TransactionDataBuilder {

    private let initialSize: Int?

    init(params: TransactionParams?, draft: TransactionSendDraft?, initialSize: Int?) {
        self.initialSize = initialSize
        super.init(params: params, draft: draft)
    }

    override func composeData() -> Data? {
        return composeAlgosTransactionData()
    }

    private func composeAlgosTransactionData() -> Data? {
        guard let params = params,
              let algosTransactionDraft = draft as? AlgosTransactionSendDraft,
              let amountDoubleValue = algosTransactionDraft.amount,
              let toAddress = algosTransactionDraft.toAccount else {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.other))
            return nil
        }

        var isMaxTransaction = algosTransactionDraft.isMaxTransaction
        var transactionAmount = amountDoubleValue.toMicroAlgos

        if isMaxTransaction {
            // Check if transaction amount is equal to amount of the sender account when it is max transaction
            if transactionAmount != algosTransactionDraft.from.amount {
                isMaxTransaction = false
            }
            // Reduce fee from transaction amount
            transactionAmount -= params.getProjectedTransactionFee(from: initialSize)
        }

        if !isValidAddress(toAddress.trimmed) {
            return nil
        }

        let draft = AlgosTransactionDraft(
            from: algosTransactionDraft.from,
            toAccount: toAddress.trimmed,
            transactionParams: params,
            amount: transactionAmount,
            isMaxTransaction: isMaxTransaction,
            note: algosTransactionDraft.note?.data(using: .utf8)
        )

        var transactionError: NSError?

        guard let transactionData = algorandSDK.sendAlgos(with: draft, error: &transactionError) else {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.sdkError(error: transactionError)))
            return nil
        }

        return transactionData
    }
}
