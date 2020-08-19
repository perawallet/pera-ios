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
    private var connectedDevice: CBPeripheral?
    
    private var fromAccount: Account? {
        return transactionDraft?.from
    }
    
    private var assetTransactionDraft: AssetTransactionSendDraft? {
        return transactionDraft as? AssetTransactionSendDraft
    }
    
    private var algosTransactionDraft: AlgosTransactionSendDraft? {
        return transactionDraft as? AlgosTransactionSendDraft
    }
    
    private var rekeyTransactionDraft: RekeyTransactionSendDraft? {
        return transactionDraft as? RekeyTransactionSendDraft
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
    
    private func setupBLEConnections() {
        let manager = BLEConnectionManager()
        manager.delegate = self
        bleConnectionManager = manager
        
        ledgerBLEController.delegate = self
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
                self.connectedDevice = nil
                self.delegate?.transactionController(self, didFailedComposing: error)
            }
        }
    }
    
    func uploadTransaction(with completion: EmptyHandler? = nil) {
        guard let transactionData = signedTransactionData else {
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
        case .rekey:
            composeRekeyTransactionData()
            startSigningProcess(for: accountType, and: .rekey)
        }
    }
}

extension TransactionController {
    private func startSigningProcess(for accountType: AccountType, and transactionType: TransactionType) {
        if accountType.requiresLedgerConnection() {
            setupBLEConnections()
            // swiftlint:disable todo
            // TODO: We need to restart scanning somehow here so that it can be restarted if there is an error in the same screen.
            // For now, it will not start scanning unless the func centralManagerDidUpdateState(_ central: CBCentralManager) delegate
            // function of central manager in BLEConnectionManager is not called.
            // swiftlint:enable todo
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
            calculateAssetTransactionFee(for: .algosTransaction)
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
                connectedDevice = nil
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
                connectedDevice = nil
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
            connectedDevice = nil
            delegate?.transactionController(self, didFailedComposing: .custom(trimmedToAddress))
            return
        }
        
        let draft = AlgosTransactionDraft(
            from: algosTransactionDraft.from,
            toAccount: trimmedToAddress,
            transactionParams: params,
            amount: transactionAmount,
            isMaxTransaction: isMaxTransaction,
            note: algosTransactionDraft.note?.data(using: .utf8)
        )
        
        var transactionError: NSError?
        
        guard let transactionData = algorandSDK.sendAlgos(with: draft, error: &transactionError) else {
            connectedDevice = nil
            delegate?.transactionController(self, didFailedComposing: .custom(transactionError))
            return
        }
        
        self.unsignedTransactionData = transactionData
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
                connectedDevice = nil
                delegate?.transactionController(self, didFailedComposing: .custom(nil))
            return
        }
        
        let trimmedToAddress = toAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !algorandSDK.isValidAddress(trimmedToAddress) {
            connectedDevice = nil
            delegate?.transactionController(self, didFailedComposing: .custom(TransactionError.invalidAddress(address: trimmedToAddress)))
            return
        }
        
        let draft = AssetTransactionDraft(
            from: transactionDraft.from,
            toAccount: trimmedToAddress,
            transactionParams: params,
            amount: amountDoubleValue.toFraction(of: transactionDraft.assetDecimalFraction),
            assetIndex: assetIndex,
            note: transactionDraft.note?.data(using: .utf8)
        )
        
        var transactionError: NSError?
        
        guard let transactionData = algorandSDK.sendAsset(with: draft, error: &transactionError) else {
            connectedDevice = nil
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
                connectedDevice = nil
                delegate?.transactionController(self, didFailedComposing: .custom(nil))
            return
        }
        
        let trimmedToAddress = toAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !algorandSDK.isValidAddress(trimmedToAddress) {
            connectedDevice = nil
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
            connectedDevice = nil
            delegate?.transactionController(self, didFailedComposing: .custom(transactionError))
            return
        }
        
        self.unsignedTransactionData = transactionData
    }

    private func composeAssetAdditionData() {
        guard let params = params,
            let assetTransactionDraft = assetTransactionDraft,
            let assetIndex = assetTransactionDraft.assetIndex else {
                connectedDevice = nil
                delegate?.transactionController(self, didFailedComposing: .custom(self.assetTransactionDraft))
                return
        }
        
        var transactionError: NSError?
        let draft = AssetAdditionDraft(from: assetTransactionDraft.from, transactionParams: params, assetIndex: assetIndex)
        
        guard let transactionData = algorandSDK.addAsset(with: draft, error: &transactionError) else {
            connectedDevice = nil
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
        
        // Asset transaction fee amount must be asset count * minimum algos limit + minimum fee
        if transactionType == .assetAddition
            && !isValidTransactionAmount(for: account, calculatedFee: calculatedFee, containsCurrentAsset: true) {
            return
        }
        
        if transactionType != .assetRemoval
            && !isValidTransactionAmount(for: account, calculatedFee: calculatedFee, containsCurrentAsset: false) {
            return
        }
        
        self.transactionDraft?.fee = calculatedFee
    }
    
    private func isValidTransactionAmount(for account: Account, calculatedFee: Int64, containsCurrentAsset: Bool) -> Bool {
        let assetCount = containsCurrentAsset ? account.assetDetails.count + 2 : account.assetDetails.count + 1
        let minimumAmount = Int64(minimumTransactionMicroAlgosLimit * assetCount) + calculatedFee
        if Int64(account.amount) < minimumAmount {
            delegate?.transactionController(self, didFailedComposing: .custom(TransactionError.minimumAmount(amount: minimumAmount)))
            return false
        }
        
        return true
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

extension TransactionController {
    private func composeRekeyTransactionData() {
        guard let params = params,
            let draft = rekeyTransactionDraft,
            let rekeyedAccount = draft.toAccount else {
                connectedDevice = nil
                delegate?.transactionController(self, didFailedComposing: .custom(self.rekeyTransactionDraft))
                return
        }
        
        var transactionError: NSError?
        let rekeyTransactionDraft = RekeyTransactionDraft(from: draft.from, rekeyedAccount: rekeyedAccount, transactionParams: params)
        
        guard let transactionData = algorandSDK.rekeyAccount(with: rekeyTransactionDraft, error: &transactionError) else {
            connectedDevice = nil
            delegate?.transactionController(self, didFailedComposing: .custom(transactionError))
            return
        }
        
        self.unsignedTransactionData = transactionData
    }
    
    private func completeRekeyTransaction() {
        uploadTransaction {
            self.delegate?.transactionController(self, didComposedTransactionDataFor: self.rekeyTransactionDraft)
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
        delegate?.transactionControllerDidStartBLEConnection(self)
        connectedDevice = peripheral
    }
    
    func bleConnectionManagerEnabledToWrite(_ bleConnectionManager: BLEConnectionManager) {
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
        guard let transactionType = currentTransactionType else {
            return
        }
        
        if data.toHexString() == ledgerTransactionCancelledCode {
            delegate?.transactionControllerDidFailToSignWithLedger(self)
            return
        }
        
        if data.toHexString() == ledgerErrorResponse {
            delegate?.transactionControllerDidFailToSignWithLedger(self)
            return
        }
        
        // Remove last to bytes, which are status codes.
        var signatureData = data
        signatureData.removeLast(2)
      
        if signatureData.isEmpty {
            delegate?.transactionControllerDidFailToSignWithLedger(self)
            return
        }
        
        var transactionError: NSError?
        
        guard let account = transactionDraft?.from,
            let transactionData = unsignedTransactionData else {
            connectedDevice = nil
            delegate?.transactionController(self, didFailedComposing: .custom(transactionError))
            return
        }
        
        if account.type == .rekeyed {
            guard let signedTransaction = algorandSDK.getSignedTransaction(
                with: account.authAddress,
                transaction: transactionData,
                from: signatureData,
                error: &transactionError
            ) else {
                connectedDevice = nil
                delegate?.transactionController(self, didFailedComposing: .custom(transactionError))
                return
            }
            
            self.signedTransactionData = signedTransaction
        } else {
            guard let signedTransaction = algorandSDK.getSignedTransaction(
                transactionData,
                from: signatureData,
                error: &transactionError
            ) else {
                connectedDevice = nil
                delegate?.transactionController(self, didFailedComposing: .custom(transactionError))
                return
            }
            
            self.signedTransactionData = signedTransaction
        }

        calculateAssetTransactionFee(for: transactionType)
        
        if transactionType == .algosTransaction {
            completeAlgosTransaction()
        } else if transactionType == .rekey {
            completeRekeyTransaction()
        } else {
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
        case rekey
    }
}

extension TransactionController {
    enum TransactionError {
        case minimumAmount(amount: Int64)
        case invalidAddress(address: String)
        case other
    }
}
