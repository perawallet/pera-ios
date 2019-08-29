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
    func transactionManagerDidComposedTransactionData(_ transactionManager: TransactionManager)
    func transactionManagerDidFailedComposingTransactionData(_ transactionManager: TransactionManager)
    func transactionManager(_ transactionManager: TransactionManager, didCompletedTransaction id: TransactionID)
    func transactionManager(_ transactionManager: TransactionManager, didFailedTransaction error: Error)
}

extension TransactionManagerDelegate {
    func transactionManagerDidComposedTransactionData(_ transactionManager: TransactionManager) {
        
    }
    
    func transactionManagerDidFailedComposingTransactionData(_ transactionManager: TransactionManager) {
        
    }
    
    func transactionManager(_ transactionManager: TransactionManager, didCompletedTransaction id: TransactionID) {
        
    }
    
    func transactionManager(_ transactionManager: TransactionManager, didFailedTransaction error: Error) {
        
    }
}

class TransactionManager {
    
    weak var delegate: TransactionManagerDelegate?
    
    private var api: API?
    private var params: TransactionParams?
    var transaction: TransactionPreviewDraft?
    var transactionData: Data?
    
    init(api: API?) {
        self.api = api
    }
    
    func composeTransactionData(for account: Account, isMaxValue: Bool) {
        api?.getTransactionParams { response in
            switch response {
            case let .success(params):
                self.params = params
                self.generateSignedData(for: account, isMaxValue: isMaxValue)
            case .failure:
                self.delegate?.transactionManagerDidFailedComposingTransactionData(self)
            }
        }
    }
    
    private func generateSignedData(for account: Account, isMaxValue: Bool, initialFee: Int64 = 274) {
        guard let params = params,
            let transaction = transaction else {
            delegate?.transactionManagerDidFailedComposingTransactionData(self)
            return
        }
        
        let firstRound = params.lastRound
        let lastRound = firstRound + 1000
        
        var transactionError: NSError?
        var transactionAmount = transaction.amount
        
        if isMaxValue {
            transactionAmount = transaction.amount - Double(initialFee)
            if transactionAmount < 0 {
                transactionAmount = 0
            }
        }
        
        guard let transactionData = TransactionMakePaymentTxn(
            transaction.fromAccount.address,
            account.address,
            params.fee,
            Int64(transactionAmount.toMicroAlgos),
            firstRound,
            lastRound,
            nil,
            isMaxValue ? account.address : "",
            "",
            params.genesisHashData,
            &transactionError
        ) else {
            delegate?.transactionManagerDidFailedComposingTransactionData(self)
            return
        }
        
        var signedTransactionError: NSError?
        
        guard let privateData = api?.session?.privateData(forAccount: transaction.fromAccount.address),
            let signedTransactionData = CryptoSignTransaction(privateData, transactionData, &signedTransactionError) else {
                delegate?.transactionManagerDidFailedComposingTransactionData(self)
                return
        }
        
        self.transactionData = signedTransactionData
        let calculatedFee = Int64(signedTransactionData.count) * params.fee
        self.transaction?.fee = calculatedFee
        
        if initialFee < calculatedFee && isMaxValue {
            generateSignedData(for: account, isMaxValue: true, initialFee: calculatedFee)
        } else {
            delegate?.transactionManagerDidComposedTransactionData(self)
        }
    }
    
    func completeTransaction() {
        guard let transactionData = transactionData else {
            return
        }
        
        api?.sendTransaction(with: transactionData) { transactionIdResponse in
            switch transactionIdResponse {
            case let .success(transactionId):
                self.delegate?.transactionManager(self, didCompletedTransaction: transactionId)
            case let .failure(error):
                self.delegate?.transactionManager(self, didFailedTransaction: error)
            }
        }
    }
}
