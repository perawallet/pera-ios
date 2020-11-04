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
    
    private var api: AlgorandAPI
    private var params: TransactionParams?
    private var transactionDraft: TransactionSendDraft?
    
    private var unsignedTransactionData: Data?
    private var signedTransactionData: Data?
    
    private lazy var bleConnectionManager = BLEConnectionManager()
    private lazy var ledgerBLEController = LedgerBLEController()
    
    private let algorandSDK = AlgorandSDK()
    
    private var currentTransactionType: TransactionType?
    private var connectedDevice: CBPeripheral?
    
    private var isCorrectLedgerAddressFetched = false
    
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
    
    init(api: AlgorandAPI) {
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
        bleConnectionManager.disconnect(from: connectedDevice)
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
            case let .failure(error, _):
                self.connectedDevice = nil
                self.delegate?.transactionController(self, didFailedComposing: .network(.unexpected(error)))
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
            case let .failure(error, _):
                self.logLedgerTransactionError()
                self.delegate?.transactionController(self, didFailedTransaction: .network(.unexpected(error)))
            }
        }
    }
    
    private func logLedgerTransactionError() {
        guard let sender = fromAccount?.address else {
            return
        }
        let unsignedTransaction = unsignedTransactionData?.base64EncodedString()
        let signedTransaction = signedTransactionData?.base64EncodedString()
        var log = LedgerTransactionErrorLog(sender: sender, unsignedTransaction: unsignedTransaction, signedTransaction: signedTransaction)
        log.record()
    }
}

extension TransactionController {
    private func composeTransactionData(for transactionType: TransactionType) {
        switch transactionType {
        case .algosTransaction:
            composeAlgosTransactionData()
            startSigningProcess(for: .algosTransaction)
        case .assetAddition:
            composeAssetAdditionData()
            startSigningProcess(for: .assetAddition)
        case .assetRemoval:
            composeAssetRemovalData()
            startSigningProcess(for: .assetRemoval)
        case .assetTransaction:
            composeAssetTransactionData()
            startSigningProcess(for: .assetTransaction)
        case .rekey:
            composeRekeyTransactionData()
            startSigningProcess(for: .rekey)
        }
    }
}

extension TransactionController {
    private func startSigningProcess(for transactionType: TransactionType) {
        guard let account = fromAccount else {
            return
        }
        
        if account.requiresLedgerConnection() {
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
                delegate?.transactionController(self, didFailedComposing: .inapp(TransactionError.sdkError(error: signedTransactionError)))
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
                delegate?.transactionController(self, didFailedComposing: .inapp(TransactionError.other))
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
            transactionAmount -= max(initialFee * params.fee, Transaction.Constant.minimumFee)
        }
        
        let trimmedToAddress = toAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !algorandSDK.isValidAddress(trimmedToAddress) {
            connectedDevice = nil
            delegate?.transactionController(self, didFailedComposing: .inapp(TransactionError.invalidAddress(address: trimmedToAddress)))
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
            delegate?.transactionController(self, didFailedComposing: .inapp(TransactionError.sdkError(error: transactionError)))
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
                delegate?.transactionController(self, didFailedComposing: .inapp(TransactionError.other))
            return
        }
        
        let trimmedToAddress = toAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !algorandSDK.isValidAddress(trimmedToAddress) {
            connectedDevice = nil
            delegate?.transactionController(self, didFailedComposing: .inapp(TransactionError.invalidAddress(address: trimmedToAddress)))
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
            delegate?.transactionController(self, didFailedComposing: .inapp(TransactionError.sdkError(error: transactionError)))
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
                delegate?.transactionController(self, didFailedComposing: .inapp(TransactionError.other))
            return
        }
        
        let trimmedToAddress = toAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !algorandSDK.isValidAddress(trimmedToAddress) {
            connectedDevice = nil
            delegate?.transactionController(self, didFailedComposing: .inapp(TransactionError.invalidAddress(address: trimmedToAddress)))
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
            delegate?.transactionController(self, didFailedComposing: .inapp(TransactionError.sdkError(error: transactionError)))
            return
        }
        
        self.unsignedTransactionData = transactionData
    }

    private func composeAssetAdditionData() {
        guard let params = params,
            let assetTransactionDraft = assetTransactionDraft,
            let assetIndex = assetTransactionDraft.assetIndex else {
                connectedDevice = nil
                delegate?.transactionController(self, didFailedComposing: .inapp(TransactionError.draft(draft: self.assetTransactionDraft)))
                return
        }
        
        var transactionError: NSError?
        let draft = AssetAdditionDraft(from: assetTransactionDraft.from, transactionParams: params, assetIndex: assetIndex)
        
        guard let transactionData = algorandSDK.addAsset(with: draft, error: &transactionError) else {
            connectedDevice = nil
            delegate?.transactionController(self, didFailedComposing: .inapp(TransactionError.sdkError(error: transactionError)))
            return
        }
        
        self.unsignedTransactionData = transactionData
    }
    
    private func calculateAssetTransactionFee(for transactionType: TransactionType) {
        guard let params = params,
            let signedTransactionData = signedTransactionData else {
            return
        }
        
        let calculatedFee = max((Int64(signedTransactionData.count) * params.fee), Transaction.Constant.minimumFee)
        
        // Asset transaction fee amount must be asset count * minimum algos limit + minimum fee
        if !isValidTransactionAmount(for: transactionType, calculatedFee: calculatedFee) {
            return
        }
        
        self.transactionDraft?.fee = calculatedFee
    }
    
    private func isValidTransactionAmount(for transactionType: TransactionType, calculatedFee: Int64) -> Bool {
        guard let account = fromAccount,
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
            delegate?.transactionController(self, didFailedComposing: .inapp(TransactionError.minimumAmount(amount: minimumAmount)))
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
                delegate?.transactionController(self, didFailedComposing: .inapp(TransactionError.draft(draft: self.rekeyTransactionDraft)))
                return
        }
        
        var transactionError: NSError?
        let rekeyTransactionDraft = RekeyTransactionDraft(from: draft.from, rekeyedAccount: rekeyedAccount, transactionParams: params)
        
        guard let transactionData = algorandSDK.rekeyAccount(with: rekeyTransactionDraft, error: &transactionError) else {
            connectedDevice = nil
            delegate?.transactionController(self, didFailedComposing: .inapp(TransactionError.sdkError(error: transactionError)))
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
        if isCorrectLedgerAddressFetched {
            signTransactionWithLedger()
        } else {
            fetchAddressFromLedger()
        }
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
        guard let transactionType = currentTransactionType,
              let account = fromAccount else {
            return
        }
        
        if !isCorrectLedgerAddressFetched {
            if data.isLedgerErrorResponse() {
                resetLedgerConnectionAndDisplayError("ble-error-ledger-connection-open-app-error".localized)
                return
            }
            
            guard let address = getValidAddress(from: data) else {
                resetLedgerConnectionAndDisplayError("ble-error-fail-fetch-account-address".localized)
                return
            }
            
            isCorrectLedgerAddressFetched = account.authAddress.unwrap(or: account.address) == address
            proceedSigningTransactionByLedgerIfPossible()
            return
        }
        
        isCorrectLedgerAddressFetched = false
        
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
        
        guard let transactionData = unsignedTransactionData else {
            connectedDevice = nil
            delegate?.transactionController(self, didFailedComposing: .inapp(TransactionError.sdkError(error: transactionError)))
            return
        }
        
        if account.isRekeyed() {
            guard let signedTransaction = algorandSDK.getSignedTransaction(
                with: account.authAddress,
                transaction: transactionData,
                from: signatureData,
                error: &transactionError
            ) else {
                connectedDevice = nil
                delegate?.transactionController(self, didFailedComposing: .inapp(TransactionError.sdkError(error: transactionError)))
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
                delegate?.transactionController(self, didFailedComposing: .inapp(TransactionError.sdkError(error: transactionError)))
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
    
    private func fetchAddressFromLedger() {
        guard let bleData = Data(fromHexEncodedString: bleLedgerAddressMessage) else {
            return
        }
        
        ledgerBLEController.fetchAddress(bleData)
    }
    
    private func signTransactionWithLedger() {
        guard let hexString = unsignedTransactionData?.toHexString(),
            let bleData = Data(fromHexEncodedString: hexString) else {
            return
        }
        
        ledgerBLEController.signTransaction(bleData)
    }
    
    private func resetLedgerConnectionAndDisplayError(_ message: String) {
        resetLedgerConnection()
        NotificationBanner.showError("ble-error-ledger-connection-title".localized, message: message)
    }
    
    private func resetLedgerConnection() {
        connectedDevice = nil
        isCorrectLedgerAddressFetched = false
    }
    
    private func getValidAddress(from data: Data) -> String? {
        // Remove last two bytes to fetch data that provides message status, not related to the account address
        var mutableData = data
        mutableData.removeLast(2)

        var error: NSError?
        let address = AlgorandSDK().addressFromPublicKey(mutableData, error: &error)
        
        return error == nil && AlgorandSDK().isValidAddress(address) ? address : nil
    }
    
    private func proceedSigningTransactionByLedgerIfPossible() {
        if isCorrectLedgerAddressFetched {
            signTransactionWithLedger()
        } else {
            resetLedgerConnectionAndDisplayError("ledger-transaction-account-match-error".localized)
            delegate?.transactionControllerDidFailToSignWithLedger(self)
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

enum TransactionError: Error {
    case minimumAmount(amount: Int64)
    case invalidAddress(address: String)
    case sdkError(error: NSError?)
    case draft(draft: TransactionSendDraft?)
    case other
}
