//
//  TransactionFeeCalculator.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import Foundation

class TransactionFeeCalculator: NSObject {

    weak var delegate: TransactionFeeCalculatorDelegate?

    private var transactionDraft: TransactionSendDraft?
    private let transactionData: TransactionData
    private let params: TransactionParams?

    init(transactionDraft: TransactionSendDraft?, transactionData: TransactionData, params: TransactionParams?) {
        self.transactionDraft = transactionDraft
        self.transactionData = transactionData
        self.params = params
    }

    func calculate(for transactionType: TransactionController.TransactionType) -> Int64? {
        guard let params = params,
              let signedTransactionData = transactionData.signedTransaction else {
            return nil
        }

        let calculatedFee = params.getProjectedTransactionFee(from: signedTransactionData.count)

        /// Asset transaction fee amount must be asset count * minimum algos limit + minimum fee
        if !isValidTransactionAmount(for: transactionType, calculatedFee: calculatedFee) {
            return nil
        }

        return calculatedFee
    }

    private func isValidTransactionAmount(for transactionType: TransactionController.TransactionType, calculatedFee: Int64) -> Bool {
        guard let account = transactionDraft?.from,
              let isMaxTransaction = transactionDraft?.isMaxTransaction,
              !isMaxTransaction else {
            return true
        }

        var assetCount = account.assetDetails.count + 1
        var transactionAmount: Int64 = 0

        switch transactionType {
        case .algosTransaction:
            transactionAmount = transactionDraft?.amount?.toMicroAlgos ?? 0
        case .assetTransaction:
            break
        case .assetAddition:
            assetCount = account.assetDetails.count + 2
        case .rekey:
            break
        case .assetRemoval:
            return true
        }

        let minimumAmount = Int64(minimumTransactionMicroAlgosLimit * assetCount) + calculatedFee
        if Int64(account.amount) - transactionAmount < minimumAmount {
            delegate?.transactionFeeCalculator(self, didFailedWith: minimumAmount)
            return false
        }

        return true
    }
}

protocol TransactionFeeCalculatorDelegate: class {
    func transactionFeeCalculator(_ transactionFeeCalculator: TransactionFeeCalculator, didFailedWith minimumAmount: Int64)
}
