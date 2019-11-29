//
//  TransactionManager.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie
import Crypto

class TransactionManager {
    
    weak var delegate: TransactionManagerDelegate?
    
    private var api: API
    private var params: TransactionParams?
    private var transactionDraft: TransactionPreviewDraft?
    private var assetTransactionDraft: AssetTransactionDraft?
    private var transactionData: Data?
    
    init(api: API) {
        self.api = api
    }
}

extension TransactionManager {
    func composeAlgoTransactionData(for account: Account, isMaxValue: Bool) {
        api.getTransactionParams { response in
            switch response {
            case let .success(params):
                self.params = params
                self.generateSignedAlgoTransactionData(for: account, isMaxValue: isMaxValue)
            case let .failure(error):
                self.delegate?.transactionManager(self, didFailedComposing: error)
            }
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
    private func generateSignedAlgoTransactionData(
        for account: Account,
        isMaxValue: Bool,
        initialFee: Int64 = Transaction.Constant.minimumFee
    ) {
        guard let params = params,
            let transactionDraft = transactionDraft else {
                delegate?.transactionManager(self, didFailedComposing: .custom(nil))
            return
        }
        
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
            params.lastRound,
            params.lastRound + 1000,
            nil,
            isMaxValue ? account.address : nil,
            nil,
            params.genesisHashData,
            &transactionError
        ) else {
            delegate?.transactionManager(self, didFailedComposing: .custom(transactionError))
            return
        }
        
        guard let signedTransactionData = sign(transactionData, for: transactionDraft.fromAccount.address) else {
            return
        }
        
        self.transactionData = signedTransactionData
        let calculatedFee = Int64(signedTransactionData.count) * params.fee
        self.transactionDraft?.fee = calculatedFee
        
        if initialFee < calculatedFee && isMaxValue {
            generateSignedAlgoTransactionData(for: account, isMaxValue: true, initialFee: Int64(signedTransactionData.count))
        } else {
            delegate?.transactionManagerDidComposedAlgoTransactionData(self, forTransaction: self.transactionDraft)
        }
    }
}

extension TransactionManager {
    func composeAssetTransactionData(for account: Account, isClosingTransaction: Bool = false) {
        api.getTransactionParams { response in
            switch response {
            case let .success(params):
                self.params = params
                self.transactAsset(for: account, isClosingTransaction: isClosingTransaction)
            case let .failure(error):
                self.delegate?.transactionManager(self, didFailedComposing: error)
            }
        }
    }
    
    private func transactAsset(for account: Account, isClosingTransaction: Bool) {
        guard let params = params,
            let transactionDraft = assetTransactionDraft,
            let assetIndex = transactionDraft.assetIndex,
            let transactionAmount = transactionDraft.amount else {
                delegate?.transactionManager(self, didFailedComposing: .custom(nil))
            return
        }
        
        let trimmedFromAddress = transactionDraft.fromAccount.address.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedToAddress = account.address.trimmingCharacters(in: .whitespacesAndNewlines)
        var transactionError: NSError?
        
        guard let transactionData = TransactionMakeAssetTransferTxn(
            trimmedFromAddress,
            trimmedToAddress,
            isClosingTransaction ? transactionDraft.assetCreator : "", // closing address should be empty
            Int64(transactionAmount),
            params.fee,
            params.lastRound,
            params.lastRound + 1000,
            nil,
            nil,
            params.genesisHashData?.base64EncodedString(),
            assetIndex,
            &transactionError
        ) else {
            delegate?.transactionManager(self, didFailedComposing: .custom(transactionError))
            return
        }

        completeAssetTransacion(with: transactionData)
    }
}

extension TransactionManager {
    func composeAssetAdditionTransactionData(for account: Account) {
        api.getTransactionParams { response in
            switch response {
            case let .success(params):
                self.params = params
                self.addAsset(to: account)
            case let .failure(error):
                self.delegate?.transactionManager(self, didFailedComposing: error)
            }
        }
    }
    
    private func addAsset(to account: Account) {
        guard let params = params,
            let transactionDraft = assetTransactionDraft,
            let assetIndex = transactionDraft.assetIndex else {
                delegate?.transactionManager(self, didFailedComposing: .custom(nil))
            return
        }
        
        let trimmedFromAddress = transactionDraft.fromAccount.address.trimmingCharacters(in: .whitespacesAndNewlines)
        var transactionError: NSError?
        
        guard let transactionData = TransactionMakeAssetAcceptanceTxn(
            trimmedFromAddress,
            params.fee,
            params.lastRound,
            params.lastRound + 1000,
            nil,
            nil,
            params.genesisHashData?.base64EncodedString(),
            assetIndex,
            &transactionError
        ) else {
            delegate?.transactionManager(self, didFailedComposing: .custom(transactionError))
            return
        }

        completeAssetTransacion(with: transactionData)
    }
}

extension TransactionManager {
    private func sign(_ data: Data, for address: String) -> Data? {
        var signedTransactionError: NSError?
        
        guard let privateData = api.session.privateData(forAccount: address),
            let signedTransactionData = CryptoSignTransaction(privateData, data, &signedTransactionError) else {
                delegate?.transactionManager(self, didFailedComposing: .custom(signedTransactionError))
                return nil
        }
        
        return signedTransactionData
    }
    
    private func completeAssetTransacion(with transactionData: Data) {
        guard let params = params,
            let transactionDraft = assetTransactionDraft,
            let signedTransactionData = sign(transactionData, for: transactionDraft.fromAccount.address) else {
            return
        }

        self.transactionData = signedTransactionData
        let calculatedFee = Int64(signedTransactionData.count) * params.fee
        self.assetTransactionDraft?.fee = calculatedFee
        
        completeTransaction()
        
        delegate?.transactionManagerDidComposedAssetTransactionData(self, forTransaction: self.assetTransactionDraft)
    }
}

extension TransactionManager {
    func setTransactionDraft(_ transactionDraft: TransactionPreviewDraft) {
        self.transactionDraft = transactionDraft
    }
    
    func setAssetTransactionDraft(_ assetTransactionDraft: AssetTransactionDraft) {
        self.assetTransactionDraft = assetTransactionDraft
    }
}

extension TransactionManager {
    enum TransactionType {
        case algoTransaction
        case assetTransaction
        case assetAddition
        case assetRemoval(asset: Asset)
    }
}
