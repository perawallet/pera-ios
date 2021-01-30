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
    private(set) var calculatedTransactionAmount: Int64?

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
              let toAddress = algosTransactionDraft.toAccount else {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.other))
            return nil
        }

        var isMaxTransaction = algosTransactionDraft.isMaxTransaction
        updateMaximumTransactionStateIfNeeded(&isMaxTransaction)
        let transactionAmount = calculateTransactionAmount(isMaxTransaction: isMaxTransaction)
        self.calculatedTransactionAmount = transactionAmount

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

    private func updateMaximumTransactionStateIfNeeded(_ isMaxTransaction: inout Bool) {
        if isMaxTransaction {
            // If transaction amount is equal to amount of the sender account when it is max transaction
            // If an account is rekeyed, it's not allowed to make max transaciton
            if !hasMaximumAccountAmountForTransaction() || isMaxTransactionFromRekeyedAccount() {
                isMaxTransaction = false
            }
        }
    }

    private func calculateTransactionAmount(isMaxTransaction: Bool) -> Int64 {
        guard let params = params,
              let algosTransactionDraft = draft as? AlgosTransactionSendDraft,
              var transactionAmount = algosTransactionDraft.amount?.toMicroAlgos else {
            return 0
        }

        let feeCalculator = TransactionFeeCalculator(transactionDraft: nil, transactionData: nil, params: params)
        let minimumAmountForAccount = feeCalculator.calculateMinimumAmount(
            for: algosTransactionDraft.from,
            with: .algosTransaction,
            calculatedFee: params.getProjectedTransactionFee(from: initialSize),
            isAfterTransaction: true
        )

        if isMaxTransaction {
            if isMaxTransactionFromRekeyedAccount() {
                // Reduce fee and minimum amount possible for the account from transaction amount
                transactionAmount -= params.getProjectedTransactionFee(from: initialSize) - minimumAmountForAccount
            } else {
                // Reduce fee from transaction amount
                transactionAmount -= params.getProjectedTransactionFee(from: initialSize)
            }
        }

        return transactionAmount
    }

    private func hasMaximumAccountAmountForTransaction() -> Bool {
        guard let algosTransactionDraft = draft as? AlgosTransactionSendDraft,
              let transactionAmount = draft?.amount?.toMicroAlgos else {
            return false
        }

        return transactionAmount == algosTransactionDraft.from.amount
    }

    private func isMaxTransactionFromRekeyedAccount() -> Bool {
        guard let algosTransactionDraft = draft as? AlgosTransactionSendDraft else {
            return false
        }

        return algosTransactionDraft.from.isRekeyed() && algosTransactionDraft.isMaxTransaction
    }
}
