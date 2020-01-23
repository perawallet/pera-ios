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
    private var transactionDraft: TransactionPreviewDraft?
    private var assetTransactionDraft: AssetTransactionDraft?
    private var transactionData: Data?
    private let algorandSDK = AlgorandSDK()
    
    init(api: API) {
        self.api = api
    }
}

extension TransactionController {
    func composeAlgoTransactionData(for account: Account, isMaxValue: Bool) {
        api.getTransactionParams { response in
            switch response {
            case let .success(params):
                self.params = params
                self.generateSignedAlgoTransactionData(for: account, isMaxValue: isMaxValue)
            case let .failure(error):
                self.delegate?.transactionController(self, didFailedComposing: error)
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
                self.delegate?.transactionController(self, didCompletedTransaction: transactionId)
            case let .failure(error):
                self.delegate?.transactionController(self, didFailedTransaction: error)
            }
        }
    }
}

extension TransactionController {
    private func generateSignedAlgoTransactionData(
        for account: Account,
        isMaxValue: Bool,
        initialFee: Int64 = Transaction.Constant.minimumFee
    ) {
        guard let params = params,
            let transactionDraft = transactionDraft else {
                delegate?.transactionController(self, didFailedComposing: .custom(nil))
            return
        }
        
        var isMaxValue = isMaxValue
        
        var transactionError: NSError?
        var transactionAmount = transactionDraft.amount.toMicroAlgos
        
        if isMaxValue {
            if transactionAmount != transactionDraft.fromAccount.amount {
                isMaxValue = false
            }
            transactionAmount -= initialFee * params.fee
        }
        
        let trimmedFromAddress = transactionDraft.fromAccount.address.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedToAddress = account.address.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !algorandSDK.isValidAddress(trimmedToAddress) {
            delegate?.transactionController(self, didFailedComposing: .custom(trimmedToAddress))
            return
        }
        
        let draft = AlgoTransactionDraft(
            from: trimmedFromAddress,
            to: trimmedToAddress,
            transactionParams: params,
            amount: transactionAmount,
            isMaxTransaction: isMaxValue
        )
        
        guard let transactionData = algorandSDK.sendAlgos(with: draft, error: &transactionError) else {
            delegate?.transactionController(self, didFailedComposing: .custom(transactionError))
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
            delegate?.transactionControllerDidComposedAlgoTransactionData(self, forTransaction: self.transactionDraft)
        }
    }
}

extension TransactionController {
    func composeAssetTransactionData(for account: Account, transactionType: TransactionType = .assetTransaction) {
        api.getTransactionParams { response in
            switch response {
            case let .success(params):
                self.params = params
                self.transactAsset(for: account, transactionType: transactionType)
            case let .failure(error):
                self.delegate?.transactionController(self, didFailedComposing: error)
            }
        }
    }
    
    private func transactAsset(for account: Account, transactionType: TransactionType) {
        guard let params = params,
            let transactionDraft = assetTransactionDraft,
            let assetIndex = transactionDraft.assetIndex,
            let amountDoubleValue = transactionDraft.amount else {
                delegate?.transactionController(self, didFailedComposing: .custom(nil))
            return
        }
        
        var transactionAmount = Int64(amountDoubleValue)
        
        if transactionType == .assetTransaction {
            transactionAmount = amountDoubleValue.toFraction(of: transactionDraft.assetDecimalFraction)
        }
        
        let trimmedFromAddress = transactionDraft.fromAccount.address.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedToAddress = account.address.trimmingCharacters(in: .whitespacesAndNewlines)
        var transactionError: NSError?
        
        if !algorandSDK.isValidAddress(trimmedToAddress) {
            delegate?.transactionController(self, didFailedComposing: .custom(trimmedToAddress))
            return
        }
        
        let draft = AssetTransactionsDraft(
            from: trimmedFromAddress,
            to: trimmedToAddress,
            transactionParams: params,
            amount: transactionAmount,
            assetIndex: assetIndex
        )
        
        guard let transactionData = algorandSDK.sendAsset(with: draft, error: &transactionError) else {
            delegate?.transactionController(self, didFailedComposing: .custom(transactionError))
            return
        }
        
        completeAssetTransacion(with: transactionData, transactionType: transactionType)
    }
    
    private func removeAsset(for account: Account, transactionType: TransactionType) {
        guard let params = params,
            let transactionDraft = assetTransactionDraft,
            let assetIndex = transactionDraft.assetIndex,
            let amountDoubleValue = transactionDraft.amount else {
                delegate?.transactionController(self, didFailedComposing: .custom(nil))
            return
        }
        
        var transactionAmount = Int64(amountDoubleValue)
        
        if transactionType == .assetTransaction {
            transactionAmount = amountDoubleValue.toFraction(of: transactionDraft.assetDecimalFraction)
        }
        
        let trimmedFromAddress = transactionDraft.fromAccount.address.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedToAddress = account.address.trimmingCharacters(in: .whitespacesAndNewlines)
        var transactionError: NSError?
        
        if !algorandSDK.isValidAddress(trimmedToAddress) {
            delegate?.transactionController(self, didFailedComposing: .custom(trimmedToAddress))
            return
        }
        
        let draft = AssetRemovalDraft(
            from: trimmedFromAddress,
            transactionParams: params,
            amount: transactionAmount,
            assetCreatorAddress: transactionDraft.assetCreator,
            assetIndex: assetIndex
        )
        
        guard let transactionData = algorandSDK.removeAsset(with: draft, error: &transactionError) else {
            delegate?.transactionController(self, didFailedComposing: .custom(transactionError))
            return
        }
        
        completeAssetTransacion(with: transactionData, transactionType: transactionType)
    }
}

extension TransactionController {
    func composeAssetAdditionTransactionData(for account: Account) {
        api.getTransactionParams { response in
            switch response {
            case let .success(params):
                self.params = params
                self.addAsset(to: account)
            case let .failure(error):
                self.delegate?.transactionController(self, didFailedComposing: error)
            }
        }
    }
    
    private func addAsset(to account: Account) {
        guard let params = params,
            let transactionDraft = assetTransactionDraft,
            let assetIndex = transactionDraft.assetIndex else {
                delegate?.transactionController(self, didFailedComposing: .custom(assetTransactionDraft))
            return
        }
        
        let trimmedFromAddress = transactionDraft.fromAccount.address.trimmingCharacters(in: .whitespacesAndNewlines)
        var transactionError: NSError?
        let draft = AssetAdditionDraft(from: trimmedFromAddress, transactionParams: params, assetIndex: assetIndex)
        
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
            let transactionDraft = assetTransactionDraft,
            let signedTransactionData = sign(transactionData, for: transactionDraft.fromAccount.address) else {
            return
        }

        self.transactionData = signedTransactionData
        
        var calculatedFee = Int64(signedTransactionData.count) * params.fee
        
        if calculatedFee < Transaction.Constant.minimumFee {
            calculatedFee = Transaction.Constant.minimumFee
        }
        
        let account = transactionDraft.fromAccount
        
        if transactionType == .assetAddition &&
            Int64(account.amount) - calculatedFee < Int64(minimumTransactionMicroAlgosLimit * (account.assetDetails.count + 2)) {
            let mininmumAmount = Int64(minimumTransactionMicroAlgosLimit * (account.assetDetails.count + 2)) + calculatedFee
            delegate?.transactionController(self, didFailedComposing: .custom(mininmumAmount))
            return
        }
        
        self.assetTransactionDraft?.fee = calculatedFee
        
        if transactionType != .assetTransaction {
            completeTransaction()
        }
        
        delegate?.transactionControllerDidComposedAssetTransactionData(self, forTransaction: self.assetTransactionDraft)
    }
}

extension TransactionController {
    private func sign(_ data: Data, for address: String) -> Data? {
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
    func setTransactionDraft(_ transactionDraft: TransactionPreviewDraft) {
        self.transactionDraft = transactionDraft
    }
    
    func setAssetTransactionDraft(_ assetTransactionDraft: AssetTransactionDraft) {
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
