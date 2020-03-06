//
//  transactionController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie
import CoreBluetooth

class TransactionController {
    weak var delegate: TransactionControllerDelegate?
    
    private var api: API
    private var params: TransactionParams?
    private var transactionDraft: TransactionSendDraft?
    
    private var unsignedTransactionData: Data?
    private var signedTransactionData: Data?
    
    private lazy var bleConnectionManager = BLEConnectionManager()
    private lazy var ledgerBLEController = LedgerBLEController()
    
    private let algorandSDK = AlgorandSDK()
    
    private var currentTransactionType: TransactionType?
    
    private var fromAccount: Account? {
        return transactionDraft?.from
    }
    
    private var assetTransactionDraft: AssetTransactionSendDraft? {
        return transactionDraft as? AssetTransactionSendDraft
    }
    
    private var algosTransactionDraft: AlgosTransactionSendDraft? {
        return transactionDraft as? AlgosTransactionSendDraft
    }
    
    private var isTransactionSigned: Bool {
        return signedTransactionData != nil
    }
    
    init(api: API) {
        self.api = api
    }
}

extension TransactionController {
    func setTransactionDraft(_ transactionDraft: TransactionSendDraft) {
        self.transactionDraft = transactionDraft
    }
    
    func setupBLEConnections() {
        if bleConnectionManager.delegate == nil {
            bleConnectionManager.delegate = self
        }
        
        if ledgerBLEController.delegate == nil {
            ledgerBLEController.delegate = self
        }
    }
    
    func stopBLEScan() {
        bleConnectionManager.stopScan()
    }
}

extension TransactionController {
    func getTransactionParamsAndComposeTransactionData(for transactionType: TransactionType) {
        currentTransactionType = transactionType
        api.getTransactionParams { response in
            switch response {
            case let .success(params):
                self.params = params
                self.composeTransactionData(for: transactionType)
            case let .failure(error):
                self.delegate?.transactionController(self, didFailedComposing: error)
            }
        }
    }
    
    func uploadTransaction(with completion: EmptyHandler? = nil) {
        guard let transactionData = signedTransactionData else {
            return
        }
        
        api.sendTransaction(with: transactionData) { transactionIdResponse in
            self.currentTransactionType = nil
            
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
    private func composeTransactionData(for transactionType: TransactionType) {
        guard let accountType = fromAccount?.type else {
            return
        }
        
        switch transactionType {
        case .algosTransaction:
            composeAlgosTransactionData()
            startSigningProcess(for: accountType, and: .algosTransaction)
        case .assetAddition:
            composeAssetAdditionData()
            startSigningProcess(for: accountType, and: .assetAddition)
        case .assetRemoval:
            composeAssetRemovalData()
            startSigningProcess(for: accountType, and: .assetRemoval)
        case .assetTransaction:
            composeAssetTransactionData()
            startSigningProcess(for: accountType, and: .assetTransaction)
        }
    }
}

extension TransactionController {
    private func startSigningProcess(for accountType: AccountType, and transactionType: TransactionType) {
        if accountType == .ledger {
            setupBLEConnections()
            bleConnectionManager.startScanForPeripherals()
        } else {
            if transactionType == .algosTransaction {
                handleAlgosTransactionForStandardAccount()
            } else {
                handleAssetTransactionForStandardAccount(for: transactionType)
            }
        }
    }
    
    private func handleAlgosTransactionForStandardAccount() {
        signTransaction()
        
        if isTransactionSigned {
            calculateAlgosTransactionFee()
            completeAlgosTransaction()
        }
    }
    
    private func handleAssetTransactionForStandardAccount(for transactionType: TransactionType) {
        signTransaction()
        
        if isTransactionSigned {
            calculateAssetTransactionFee(for: transactionType)
            completeAssetTransaction(for: transactionType)
        }
    }
    
    private func signTransaction() {
        var signedTransactionError: NSError?
        
        guard let unsignedTransactionData = unsignedTransactionData,
            let accountAddress = fromAccount?.address,
            let privateData = api.session.privateData(for: accountAddress),
            let signedTransactionData = algorandSDK.sign(privateData, with: unsignedTransactionData, error: &signedTransactionError) else {
                delegate?.transactionController(self, didFailedComposing: .custom(signedTransactionError))
                return
        }
        
        self.signedTransactionData = signedTransactionData
    }
}

extension TransactionController {
    private func composeAlgosTransactionData(initialFee: Int64 = Transaction.Constant.minimumFee) {
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
        
        self.unsignedTransactionData = transactionData
    }
    
    private func calculateAlgosTransactionFee() {
        guard let params = params,
            let signedTransactionData = signedTransactionData else {
            return
        }
        
        let calculatedFee = Int64(signedTransactionData.count) * params.fee
        self.transactionDraft?.fee = calculatedFee
    }
        
    private func completeAlgosTransaction() {
        guard let calculatedFee = transactionDraft?.fee,
            let algosTransactionDraft = algosTransactionDraft,
            let signedTransactionData = signedTransactionData else {
            return
        }
        
        // Re-sign transaction if the calculated fee is more than the minimum fee
        if Transaction.Constant.minimumFee < calculatedFee && algosTransactionDraft.isMaxTransaction {
            composeAlgosTransactionData(initialFee: Int64(signedTransactionData.count))
        } else {
            delegate?.transactionController(self, didComposedTransactionDataFor: self.algosTransactionDraft)
        }
    }
}

extension TransactionController {
    private func composeAssetTransactionData() {
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
        
        self.unsignedTransactionData = transactionData
    }
    
    private func composeAssetRemovalData() {
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
        
        self.unsignedTransactionData = transactionData
    }

    private func composeAssetAdditionData() {
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
        
        self.unsignedTransactionData = transactionData
    }
    
    private func calculateAssetTransactionFee(for transactionType: TransactionType) {
        guard let params = params,
            let signedTransactionData = signedTransactionData,
            let account = fromAccount else {
            return
        }
        
        var calculatedFee = Int64(signedTransactionData.count) * params.fee
        
        if calculatedFee < Transaction.Constant.minimumFee {
            calculatedFee = Transaction.Constant.minimumFee
        }
        
        // Asset addition fee amount must be asset count * minimum algos limit + minimum fee
        if transactionType == .assetAddition &&
            Int64(account.amount) - calculatedFee < Int64(minimumTransactionMicroAlgosLimit * (account.assetDetails.count + 2)) {
            let mininmumAmount = Int64(minimumTransactionMicroAlgosLimit * (account.assetDetails.count + 2)) + calculatedFee
            delegate?.transactionController(self, didFailedComposing: .custom(mininmumAmount))
            return
        }
        
        self.transactionDraft?.fee = calculatedFee
    }
    
    private func completeAssetTransaction(for transactionType: TransactionType) {
        // Asset addition and removal actions do not have approve part, so transaction should be completed here.
        if transactionType != .assetTransaction {
            uploadTransaction {
                self.delegate?.transactionController(self, didComposedTransactionDataFor: self.assetTransactionDraft)
            }
        } else {
            delegate?.transactionController(self, didComposedTransactionDataFor: self.assetTransactionDraft)
        }
    }
}

extension TransactionController: BLEConnectionManagerDelegate {
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didDiscover peripherals: [CBPeripheral]) {
        guard let ledgerDetail = fromAccount?.ledgerDetail,
            let savedPeripheralId = ledgerDetail.id,
            let savedPeripheral = peripherals.first(where: { $0.identifier == savedPeripheralId }) else {
            return
        }
        
        bleConnectionManager.connectToDevice(savedPeripheral)
    }
    
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didConnect peripheral: CBPeripheral) {
        guard let hexString = unsignedTransactionData?.toHexString(),
            let bleData = Data(fromHexEncodedString: hexString) else {
            return
        }
        
        ledgerBLEController.signTransaction(bleData)
    }
    
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didRead string: String) {
        ledgerBLEController.updateIncomingData(with: string)
    }
    
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didFailBLEConnectionWith state: CBManagerState) {
        delegate?.transactionController(self, didFailBLEConnectionWith: state)
    }
    
    func bleConnectionManager(
        _ bleConnectionManager: BLEConnectionManager,
        didFailToConnect peripheral: CBPeripheral,
        with error: BLEError?
    ) {
        delegate?.transactionController(self, didFailToConnect: peripheral)
    }
    
    func bleConnectionManager(
        _ bleConnectionManager: BLEConnectionManager,
        didDisconnectFrom peripheral: CBPeripheral,
        with error: BLEError?
    ) {
        delegate?.transactionController(self, didDisconnectFrom: peripheral)
    }
}

extension TransactionController: LedgerBLEControllerDelegate {
    func ledgerBLEController(_ ledgerBLEController: LedgerBLEController, shouldWrite data: Data) {
        bleConnectionManager.write(data)
    }
    
    func ledgerBLEController(_ ledgerBLEController: LedgerBLEController, received data: Data) {
        // Remove last to bytes, which are status codes.
        var signatureData = data
        signatureData.removeLast(2)
      
        var transactionError: NSError?
      
        guard let transactionData = unsignedTransactionData,
            let signedTransaction = algorandSDK.getSignedTransaction(transactionData, from: signatureData, error: &transactionError),
            let transactionType = currentTransactionType else {
                delegate?.transactionController(self, didFailedComposing: .custom(transactionError))
                return
        }
      
        self.signedTransactionData = signedTransaction
        
        if transactionType == .algosTransaction {
            calculateAlgosTransactionFee()
            completeAlgosTransaction()
        } else {
            calculateAssetTransactionFee(for: transactionType)
            completeAssetTransaction(for: transactionType)
        }
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
