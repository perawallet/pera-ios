//
//  transactionController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class TransactionController {
    weak var delegate: TransactionControllerDelegate?
    
    private var api: API
    private var params: TransactionParams?
    private var algosTransactionDraft: AlgosTransactionSendDraft?
    private var assetTransactionDraft: AssetTransactionSendDraft?
    private var transactionData: Data?
    
    private let algorandSDK = AlgorandSDK()
    
    init(api: API) {
        self.api = api
    }
}

extension TransactionController {
    func composeAlgosTransactionData() {
        api.getTransactionParams { response in
            switch response {
            case let .success(params):
                self.params = params
                self.generateSignedAlgosTransactionData()
            case let .failure(error):
                self.delegate?.transactionController(self, didFailedComposing: error)
            }
        }
    }
    
    func composeAssetTransactionData(transactionType: TransactionType) {
        api.getTransactionParams { response in
            switch response {
            case let .success(params):
                self.params = params
                
                if transactionType == .assetAddition {
                    self.addAsset()
                } else if transactionType == .assetRemoval {
                    self.removeAsset()
                } else if transactionType == .assetTransaction {
                    self.transactAsset()
                }
            case let .failure(error):
                self.delegate?.transactionController(self, didFailedComposing: error)
            }
        }
    }
    
    func sendTransaction(with completion: EmptyHandler? = nil) {
        guard let transactionData = transactionData else {
            return
        }
        
        api.sendTransaction(with: transactionData) { transactionIdResponse in
            switch transactionIdResponse {
            case let .success(transactionId):
                self.api.trackTransaction(with: TransactionTrackDraft(transactionId: transactionId.identifier))
                completion?()
                self.delegate?.transactionController(self, didCompletedTransaction: transactionId)
            case let .failure(error):
                self.delegate?.transactionController(self, didFailedTransaction: error)
            }
        }
    }
}

extension TransactionController {
    private func generateSignedAlgosTransactionData(initialFee: Int64 = Transaction.Constant.minimumFee) {
        guard let params = params,
            let algosTransactionDraft = algosTransactionDraft,
            let amountDoubleValue = algosTransactionDraft.amount,
            let toAddress = algosTransactionDraft.toAccount else {
                delegate?.transactionController(self, didFailedComposing: .custom(nil))
            return
        }
        
        var isMaxTransaction = algosTransactionDraft.isMaxTransaction
        var transactionAmount = amountDoubleValue.toMicroAlgos
        
        if isMaxTransaction {
            // Check if transaction amount is equal to amount of the sender account when it is max transaction
            if transactionAmount != algosTransactionDraft.from.amount {
                isMaxTransaction = false
            }
            // Reduce fee from transaction amount
            transactionAmount -= initialFee * params.fee
        }
        
        let trimmedToAddress = toAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !algorandSDK.isValidAddress(trimmedToAddress) {
            delegate?.transactionController(self, didFailedComposing: .custom(trimmedToAddress))
            return
        }
        
        let draft = AlgosTransactionDraft(
            from: algosTransactionDraft.from,
            toAccount: trimmedToAddress,
            transactionParams: params,
            amount: transactionAmount,
            isMaxTransaction: isMaxTransaction
        )
        
        var transactionError: NSError?
        
        guard let transactionData = algorandSDK.sendAlgos(with: draft, error: &transactionError) else {
            delegate?.transactionController(self, didFailedComposing: .custom(transactionError))
            return
        }
        
        guard let signedTransactionData = sign(transactionData, with: algosTransactionDraft.from.address) else {
            return
        }
        
        self.transactionData = signedTransactionData
        let calculatedFee = Int64(signedTransactionData.count) * params.fee
        self.algosTransactionDraft?.fee = calculatedFee
        
        // Re-sign transaction if the calculated fee is more than the minimum fee
        if initialFee < calculatedFee && isMaxTransaction {
            generateSignedAlgosTransactionData(initialFee: Int64(signedTransactionData.count))
        } else {
            delegate?.transactionControllerDidComposedAlgosTransactionData(self, forTransaction: self.algosTransactionDraft)
        }
    }
}

extension TransactionController {
    private func transactAsset() {
        guard let params = params,
            let transactionDraft = assetTransactionDraft,
            let assetIndex = transactionDraft.assetIndex,
            let amountDoubleValue = transactionDraft.amount,
            let toAddress = transactionDraft.toAccount else {
                delegate?.transactionController(self, didFailedComposing: .custom(nil))
            return
        }
        
        let trimmedToAddress = toAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !algorandSDK.isValidAddress(trimmedToAddress) {
            delegate?.transactionController(self, didFailedComposing: .custom(trimmedToAddress))
            return
        }
        
        let draft = AssetTransactionDraft(
            from: transactionDraft.from,
            toAccount: trimmedToAddress,
            transactionParams: params,
            amount: amountDoubleValue.toFraction(of: transactionDraft.assetDecimalFraction),
            assetIndex: assetIndex
        )
        
        var transactionError: NSError?
        
        guard let transactionData = algorandSDK.sendAsset(with: draft, error: &transactionError) else {
            delegate?.transactionController(self, didFailedComposing: .custom(transactionError))
            return
        }
        
        completeAssetTransacion(with: transactionData, transactionType: .assetTransaction)
    }
    
    private func removeAsset() {
        guard let params = params,
            let transactionDraft = assetTransactionDraft,
            let assetIndex = transactionDraft.assetIndex,
            let amountDoubleValue = transactionDraft.amount,
            let toAddress = transactionDraft.toAccount else {
                delegate?.transactionController(self, didFailedComposing: .custom(nil))
            return
        }
        
        let trimmedToAddress = toAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !algorandSDK.isValidAddress(trimmedToAddress) {
            delegate?.transactionController(self, didFailedComposing: .custom(trimmedToAddress))
            return
        }
        
        let draft = AssetRemovalDraft(
            from: transactionDraft.from,
            transactionParams: params,
            amount: Int64(amountDoubleValue),
            assetCreatorAddress: transactionDraft.assetCreator,
            assetIndex: assetIndex
        )
        
        var transactionError: NSError?
        
        guard let transactionData = algorandSDK.removeAsset(with: draft, error: &transactionError) else {
            delegate?.transactionController(self, didFailedComposing: .custom(transactionError))
            return
        }
        
        completeAssetTransacion(with: transactionData, transactionType: .assetRemoval)
    }

    private func addAsset() {
        guard let params = params,
            let assetTransactionDraft = assetTransactionDraft,
            let assetIndex = assetTransactionDraft.assetIndex else {
                delegate?.transactionController(self, didFailedComposing: .custom(self.assetTransactionDraft))
            return
        }
        
        var transactionError: NSError?
        let draft = AssetAdditionDraft(from: assetTransactionDraft.from, transactionParams: params, assetIndex: assetIndex)
        
        guard let transactionData = algorandSDK.addAsset(with: draft, error: &transactionError) else {
            delegate?.transactionController(self, didFailedComposing: .custom(transactionError))
            return
        }

        completeAssetTransacion(with: transactionData, transactionType: .assetAddition)
    }
}

extension TransactionController {
    private func completeAssetTransacion(with transactionData: Data, transactionType: TransactionType) {
        guard let params = params,
            let assetTransactionDraft = assetTransactionDraft,
            let signedTransactionData = sign(transactionData, with: assetTransactionDraft.from.address) else {
            return
        }

        self.transactionData = signedTransactionData
        
        var calculatedFee = Int64(signedTransactionData.count) * params.fee
        
        if calculatedFee < Transaction.Constant.minimumFee {
            calculatedFee = Transaction.Constant.minimumFee
        }
        
        let account = assetTransactionDraft.from
        
        // Asset addition fee amount must be asset count * minimum algos limit + minimum fee
        if transactionType == .assetAddition &&
            Int64(account.amount) - calculatedFee < Int64(minimumTransactionMicroAlgosLimit * (account.assetDetails.count + 2)) {
            let mininmumAmount = Int64(minimumTransactionMicroAlgosLimit * (account.assetDetails.count + 2)) + calculatedFee
            delegate?.transactionController(self, didFailedComposing: .custom(mininmumAmount))
            return
        }
        
        self.assetTransactionDraft?.fee = calculatedFee
        
        // Asset addition and removal actions do not have approve part, so transaction should be completed here.
        if transactionType != .assetTransaction {
            sendTransaction {
                self.delegate?.transactionControllerDidComposedAssetTransactionData(self, forTransaction: self.assetTransactionDraft)
            }
        } else {
            delegate?.transactionControllerDidComposedAssetTransactionData(self, forTransaction: self.assetTransactionDraft)
        }
    }
}

extension TransactionController {
    private func sign(_ data: Data, with address: String) -> Data? {
        var signedTransactionError: NSError?
        
        guard let privateData = api.session.privateData(forAccount: address),
            let signedTransactionData = algorandSDK.sign(privateData, with: data, error: &signedTransactionError) else {
                delegate?.transactionController(self, didFailedComposing: .custom(signedTransactionError))
                return nil
        }
        
        return signedTransactionData
    }
}

extension TransactionController {
    func setTransactionDraft(_ algosTransactionDraft: AlgosTransactionSendDraft) {
        self.algosTransactionDraft = algosTransactionDraft
    }
    
    func setAssetTransactionDraft(_ assetTransactionDraft: AssetTransactionSendDraft) {
        self.assetTransactionDraft = assetTransactionDraft
    }
}

extension TransactionController {
    enum TransactionType {
        case algosTransaction
        case assetTransaction
        case assetAddition
        case assetRemoval
    }
}
