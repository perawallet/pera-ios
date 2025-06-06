// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  AlgoTransactionDataBuilder.swift

import Foundation

final class AlgoTransactionDataBuilder: TransactionDataBuildable {
    var eventHandler: ((TransactionDataBuildableEvent) -> Void)?
    
    private(set) var calculatedTransactionAmount: UInt64?
    private(set) var minimumAccountBalance: UInt64?
    
    let params: TransactionParams
    let draft: TransactionSendDraft
    
    private let algorandSDK = AlgorandSDK()
    private let initialSize: Int?
    
    init(
        params: TransactionParams,
        draft: TransactionSendDraft,
        initialSize: Int?
    ) {
        self.params = params
        self.draft = draft
        self.initialSize = initialSize
    }
    
    func composeData() -> [TransactionDataItem]? {
        return composeAlgosTransactionData()
    }
}

private extension AlgoTransactionDataBuilder {
    func composeAlgosTransactionData() -> [TransactionDataItem]? {
        guard let algosTransactionDraft = draft as? AlgosTransactionSendDraft else {
            eventHandler?(
                .didFailedComposing(
                    error: .inapp(
                        TransactionError.other
                    )
                )
            )
            return nil
        }

        let toAccount = algosTransactionDraft.toAccount
        let toContact = algosTransactionDraft.toContact

        guard let address = toAccount?.address ?? toContact?.address else {
            eventHandler?(
                .didFailedComposing(
                    error: .inapp(
                        TransactionError.other
                    )
                )
            )
            return nil
        }

        var isMaxTransaction = algosTransactionDraft.isMaxTransaction
        let transactionAmount = calculateTransactionAmount(isMaxTransaction: isMaxTransaction)
        self.calculatedTransactionAmount = transactionAmount
        updateMaximumTransactionStateIfNeeded(&isMaxTransaction)

        if !isValidAddress(address.trimmed()) || transactionAmount.isBelowZero {
            return nil
        }

        let note = algosTransactionDraft.lockedNote ?? algosTransactionDraft.note
        
        let draft = AlgosTransactionDraft(
            from: algosTransactionDraft.from,
            toAccount: address,
            transactionParams: params,
            amount: transactionAmount,
            isMaxTransaction: isMaxTransaction,
            note: note?.data(using: .utf8)
        )

        var transactionError: NSError?

        guard let transactionData = algorandSDK.sendAlgos(with: draft, error: &transactionError) else {
            eventHandler?(
                .didFailedComposing(
                    error: .inapp(
                        TransactionError.sdkError(error: transactionError)
                    )
                )
            )
            return nil
        }

        return  [
            TransactionDataItem(
                sender: algosTransactionDraft.from.address,
                transaction: transactionData
            )
        ]
    }

    func updateMaximumTransactionStateIfNeeded(_ isMaxTransaction: inout Bool) {
        if isMaxTransaction {
            // If transaction amount is equal to amount of the sender account when it is max transaction
            // If an account is rekeyed, it's not allowed to make max transaciton
            // If account has assets, it cannot complete max transaction
            isMaxTransaction = canSendMaxTransactions()
        }
    }

    func calculateTransactionAmount(isMaxTransaction: Bool) -> UInt64 {
        guard let algosTransactionDraft = draft as? AlgosTransactionSendDraft,
              var transactionAmount = algosTransactionDraft.amount?.toMicroAlgos else {
            return 0
        }

        let feeCalculator = TransactionFeeCalculator(transactionDraft: nil, transactionData: nil, params: params)
        let calculatedFee = params.getProjectedTransactionFee(from: initialSize)
        let minimumAmountForAccount = feeCalculator.calculateMinimumAmount(
            for: algosTransactionDraft.from,
            with: .algo,
            calculatedFee: calculatedFee,
            isAfterTransaction: true
        )

        let result = minimumAmountForAccount.subtractingReportingOverflow(calculatedFee)
        self.minimumAccountBalance = result.overflow ? minimumAmountForAccount : result.partialValue

        if isMaxTransaction {
            if isMaxTransactionFromRekeyedAccount() || hasMinAmountFieldsForMaxTransaction() {
                // Reduce fee and minimum amount possible for the account from transaction amount
                let reduceAmount = calculatedFee + (minimumAccountBalance ?? minimumAmountForAccount)
                let result = transactionAmount.subtractingReportingOverflow(reduceAmount)
                transactionAmount = result.overflow ? 0 : result.partialValue
            } else {
                // Reduce fee from transaction amount
                let result = transactionAmount.subtractingReportingOverflow(calculatedFee)
                transactionAmount = result.overflow ? 0 : result.partialValue
            }
        }

        if transactionAmount.isBelowZero {
            transactionAmount = 0
        }

        return transactionAmount
    }

    func canSendMaxTransactions() -> Bool {
        return !isMaxTransactionFromRekeyedAccount() && !hasMinAmountFieldsForMaxTransaction() && hasMaximumAccountAmountForTransaction()
    }

    func isMaxTransactionFromRekeyedAccount() -> Bool {
        guard let algosTransactionDraft = draft as? AlgosTransactionSendDraft else {
            return false
        }

        return algosTransactionDraft.isMaxTransactionFromRekeyedAccount
    }

    func hasMinAmountFieldsForMaxTransaction() -> Bool {
        guard let algosTransactionDraft = draft as? AlgosTransactionSendDraft else {
            return false
        }

        return algosTransactionDraft.from.hasDifferentMinBalance && algosTransactionDraft.isMaxTransaction
    }

    func hasMaximumAccountAmountForTransaction() -> Bool {
        guard let algosTransactionDraft = draft as? AlgosTransactionSendDraft,
              let transactionAmount = draft.amount?.toMicroAlgos else {
            return false
        }

        return transactionAmount == algosTransactionDraft.from.algo.amount
    }
}
