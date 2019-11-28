//
//  TransactionManager.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie
import Crypto

protocol TransactionManagerDelegate: class {
    func transactionManagerDidComposedTransactionData(
        _ transactionManager: TransactionManager,
        forTransaction draft: TransactionPreviewDraft?
    )
    func transactionManager(_ transactionManager: TransactionManager, didFailedComposing error: Error)
    func transactionManager(_ transactionManager: TransactionManager, didCompletedTransaction id: TransactionID)
    func transactionManager(_ transactionManager: TransactionManager, didFailedTransaction error: Error)
}

extension TransactionManagerDelegate {
    func transactionManagerDidComposedTransactionData(
        _ transactionManager: TransactionManager,
        forTransaction draft: TransactionPreviewDraft?
    ) {
        
    }
    
    func transactionManager(_ transactionManager: TransactionManager, didFailedComposing error: Error) {
        
    }
    
    func transactionManager(_ transactionManager: TransactionManager, didCompletedTransaction id: TransactionID) {
        
    }
    
    func transactionManager(_ transactionManager: TransactionManager, didFailedTransaction error: Error) {
        
    }
}

class TransactionManager {
    
    weak var delegate: TransactionManagerDelegate?
    
    private var api: API
    private var params: TransactionParams?
    private var transactionDraft: TransactionPreviewDraft?
    private var transactionData: Data?
    
    init(api: API) {
        self.api = api
    }
    
    func composeTransactionData(for account: Account, isMaxValue: Bool) {
        api.getTransactionParams { response in
            switch response {
            case let .success(params):
                self.params = params
                self.generateSignedData(for: account, isMaxValue: isMaxValue)
            case let .failure(error):
                self.delegate?.transactionManager(self, didFailedComposing: error)
            }
        }
    }
    
    private func generateSignedData(for account: Account, isMaxValue: Bool, initialFee: Int64 = Transaction.Constant.minimumFee) {
        guard let params = params,
            let transactionDraft = transactionDraft else {
                delegate?.transactionManager(self, didFailedComposing: .custom(nil))
            return
        }
        
        let firstRound = params.lastRound
        let lastRound = firstRound + 1000
        var isMaxValue = isMaxValue
        
        var transactionError: NSError?
        var transactionAmount = transactionDraft.amount.toMicroAlgos
        
        if isMaxValue {
            if transactionDraft.amount.toMicroAlgos != transactionDraft.fromAccount.amount {
                isMaxValue = false
            }
            transactionAmount -= initialFee * params.fee
        }
        
        let trimmedFromAddress = transactionDraft.fromAccount.address.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedToAddress = account.address.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let transactionData = TransactionMakePaymentTxn(
            trimmedFromAddress,
            trimmedToAddress,
            params.fee,
            transactionAmount,
            firstRound,
            lastRound,
            nil,
            isMaxValue ? account.address : nil,
            nil,
            params.genesisHashData,
            &transactionError
        ) else {
            delegate?.transactionManager(self, didFailedComposing: .custom(transactionError))
            return
        }
        
        var signedTransactionError: NSError?
        
        guard let privateData = api.session.privateData(forAccount: transactionDraft.fromAccount.address),
            let signedTransactionData = CryptoSignTransaction(privateData, transactionData, &signedTransactionError) else {
                delegate?.transactionManager(self, didFailedComposing: .custom(signedTransactionError))
                return
        }
        
        self.transactionData = signedTransactionData
        let calculatedFee = Int64(signedTransactionData.count) * params.fee
        self.transactionDraft?.fee = calculatedFee
        
        if initialFee < calculatedFee && isMaxValue {
            generateSignedData(for: account, isMaxValue: true, initialFee: Int64(signedTransactionData.count))
        } else {
            delegate?.transactionManagerDidComposedTransactionData(self, forTransaction: self.transactionDraft)
        }
    }
    
    func completeTransaction() {
        guard let transactionData = transactionData else {
            return
        }
        
        api.sendTransaction(with: transactionData) { transactionIdResponse in
            switch transactionIdResponse {
            case let .success(transactionId):
                self.api.trackTransaction(with: TransactionTrackDraft(transactionId: transactionId.identifier))
                self.delegate?.transactionManager(self, didCompletedTransaction: transactionId)
            case let .failure(error):
                self.delegate?.transactionManager(self, didFailedTransaction: error)
            }
        }
    }
}

extension TransactionManager {
    func setTransactionDraft(_ transactionDraft: TransactionPreviewDraft) {
        self.transactionDraft = transactionDraft
    }
}
