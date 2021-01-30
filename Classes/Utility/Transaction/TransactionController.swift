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
    
    private var api: AlgorandAPI
    private var params: TransactionParams?
    private var transactionDraft: TransactionSendDraft?
    
    private let transactionData = TransactionData()
    
    private lazy var ledgerTransactionOperation = LedgerTransactionOperation(api: api)

    private lazy var transactionAPIConnector = TransactionAPIConnector(api: api)
    
    private var currentTransactionType: TransactionType?
    
    init(api: AlgorandAPI) {
        self.api = api
    }
}

extension TransactionController {
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
        return transactionData.signedTransaction != nil
    }
}

extension TransactionController {
    func setTransactionDraft(_ transactionDraft: TransactionSendDraft) {
        self.transactionDraft = transactionDraft
    }
    
    func stopBLEScan() {
        ledgerTransactionOperation.disconnectFromCurrentDevice()
        ledgerTransactionOperation.stopScan()
    }

    func startTimer() {
        ledgerTransactionOperation.delegate = self
        ledgerTransactionOperation.startTimer()
    }

    func stopTimer() {
        ledgerTransactionOperation.stopTimer()
    }

    func initializeLedgerTransactionAccount() {
        if let account = fromAccount {
            ledgerTransactionOperation.setTransactionAccount(account)
        }
    }
}

extension TransactionController {
    func getTransactionParamsAndComposeTransactionData(for transactionType: TransactionType) {
        currentTransactionType = transactionType
        transactionAPIConnector.getTransactionParams { params, error in
            guard let params = params else {
                self.resetLedgerOperationIfNeeded()
                if let error = error {
                    self.delegate?.transactionController(self, didFailedComposing: .network(.unexpected(error)))
                }
                return
            }

            self.params = params
            self.composeTransactionData(for: transactionType)
        }
    }
    
    func uploadTransaction(with completion: EmptyHandler? = nil) {
        guard let transactionData = transactionData.signedTransaction else {
            return
        }

        transactionAPIConnector.uploadTransaction(transactionData) { transactionId, error in
            guard let id = transactionId else {
                self.resetLedgerOperationIfNeeded()
                self.logLedgerTransactionError()
                if let error = error {
                    self.delegate?.transactionController(self, didFailedTransaction: .network(.unexpected(error)))
                }
                return
            }

            completion?()
            self.delegate?.transactionController(self, didCompletedTransaction: id)
        }
    }
}

extension TransactionController {
    private func composeTransactionData(for transactionType: TransactionType, initialSize: Int? = nil) {
        switch transactionType {
        case .algosTransaction:
            let builder = SendAlgosTransactionDataBuilder(params: params, draft: algosTransactionDraft, initialSize: initialSize)
            if let calculatedTransactionAmount = builder.calculatedTransactionAmount?.toAlgos {
                transactionDraft?.amount = calculatedTransactionAmount
            }
            composeTransactionData(from: builder)
        case .assetAddition:
            composeTransactionData(from: AddAssetTransactionDataBuilder(params: params, draft: assetTransactionDraft))
        case .assetRemoval:
            composeTransactionData(from: RemoveAssetTransactionDataBuilder(params: params, draft: assetTransactionDraft))
        case .assetTransaction:
            composeTransactionData(from: SendAssetTransactionDataBuilder(params: params, draft: assetTransactionDraft))
        case .rekey:
            composeTransactionData(from: RekeyTransactionDataBuilder(params: params, draft: rekeyTransactionDraft))
        }

        startSigningProcess(for: transactionType)
    }

    private func composeTransactionData(from builder: TransactionDataBuilder) {
        builder.delegate = self

        guard let data = builder.composeData() else {
            resetLedgerOperationIfNeeded()
            return
        }

        transactionData.setUnsignedTransaction(data)
    }

    private func startSigningProcess(for transactionType: TransactionType) {
        guard let account = fromAccount else {
            return
        }

        if account.requiresLedgerConnection() {
            ledgerTransactionOperation.setUnsignedTransactionData(transactionData.unsignedTransaction)
            ledgerTransactionOperation.startScan()
        } else {
            handleStandardAccountSigning(with: transactionType)
        }
    }
}

extension TransactionController {
    private func handleStandardAccountSigning(with transactionType: TransactionType) {
        signTransactionForStandardAccount()
        
        if isTransactionSigned {
            calculateTransactionFee(for: transactionType)
            if transactionType == .algosTransaction {
                completeAlgosTransaction()
            } else {
                completeAssetTransaction(for: transactionType)
            }
        }
    }

    private func signTransactionForStandardAccount() {
        guard let accountAddress = fromAccount?.address,
              let privateData = api.session.privateData(for: accountAddress) else {
            return
        }

        sign(privateData, with: SDKTransactionSigner())
    }

    private func sign(_ privateData: Data?, with signer: TransactionSigner) {
        signer.delegate = self

        guard let unsignedTransactionData = transactionData.unsignedTransaction,
              let signedTransaction = signer.sign(unsignedTransactionData, with: privateData) else {
            return
        }

        transactionData.setSignedTransaction(signedTransaction)
    }
}

extension TransactionController: LedgerTransactionOperationDelegate {
    func ledgerTransactionOperation(_ ledgerTransactionOperation: LedgerTransactionOperation, didReceiveSignature data: Data) {
        signTransactionForLedgerAccount(with: data)
    }

    private func signTransactionForLedgerAccount(with data: Data) {
        guard let transactionType = currentTransactionType,
              let account = fromAccount else {
            return
        }

        sign(data, with: LedgerTransactionSigner(account: account))
        calculateTransactionFee(for: transactionType)
        completeLedgerTransaction(for: transactionType)
    }

    private func completeLedgerTransaction(for transactionType: TransactionType) {
        if transactionType == .algosTransaction {
            completeAlgosTransaction()
        } else if transactionType == .rekey {
            completeRekeyTransaction()
        } else {
            completeAssetTransaction(for: transactionType)
        }
    }

    func ledgerTransactionOperation(_ ledgerTransactionOperation: LedgerTransactionOperation, didFailed error: LedgerOperationError) { }
}

extension TransactionController {
    private func calculateTransactionFee(for transactionType: TransactionType) {
        let feeCalculator = TransactionFeeCalculator(
            transactionDraft: transactionDraft,
            transactionData: transactionData,
            params: params
        )
        self.transactionDraft?.fee = feeCalculator.calculate(for: transactionType)
    }
}

extension TransactionController {
    private func completeAlgosTransaction() {
        guard let calculatedFee = transactionDraft?.fee,
              let params = params,
              let signedTransactionData = transactionData.signedTransaction else {
            return
        }
        
        /// Re-sign transaction if the calculated fee is not matching with the projected fee
        if params.getProjectedTransactionFee(from: signedTransactionData.count) != calculatedFee {
            composeTransactionData(for: .algosTransaction, initialSize: signedTransactionData.count)
        } else {
            delegate?.transactionController(self, didComposedTransactionDataFor: self.algosTransactionDraft)
        }
    }

    private func completeAssetTransaction(for transactionType: TransactionType) {
        /// Asset addition and removal actions do not have approve part, so transaction should be completed here.
        if transactionType != .assetTransaction {
            uploadTransaction {
                self.delegate?.transactionController(self, didComposedTransactionDataFor: self.assetTransactionDraft)
            }
        } else {
            delegate?.transactionController(self, didComposedTransactionDataFor: self.assetTransactionDraft)
        }
    }

    private func completeRekeyTransaction() {
        uploadTransaction {
            self.delegate?.transactionController(self, didComposedTransactionDataFor: self.rekeyTransactionDraft)
        }
    }
}

extension TransactionController: TransactionDataBuilderDelegate {
    func transactionDataBuilder(_ transactionDataBuilder: TransactionDataBuilder, didFailedComposing error: HIPError<TransactionError>) {
        handleTransactionComposingError(error)
    }

    private func handleTransactionComposingError(_ error: HIPError<TransactionError>) {
        resetLedgerOperationIfNeeded()
        delegate?.transactionController(self, didFailedComposing: error)
    }
}

extension TransactionController: TransactionSignerDelegate {
    func transactionSigner(_ transactionSigner: TransactionSigner, didFailedSigning error: HIPError<TransactionError>) {
        handleTransactionComposingError(error)
    }
}

extension TransactionController: TransactionFeeCalculatorDelegate {
    func transactionFeeCalculator(_ transactionFeeCalculator: TransactionFeeCalculator, didFailedWith minimumAmount: Int64) {
        handleTransactionComposingError(.inapp(TransactionError.minimumAmount(amount: minimumAmount)))
    }
}

extension TransactionController {
    private func resetLedgerOperationIfNeeded() {
        if fromAccount?.requiresLedgerConnection() ?? false {
            ledgerTransactionOperation.reset()
        }
    }
}

extension TransactionController {
    private func logLedgerTransactionError() {
        guard let account = fromAccount,
              account.requiresLedgerConnection() else {
            return
        }
        
        UIApplication.shared.firebaseAnalytics?.record(
            LedgerTransactionErrorLog(account: account, transactionData: transactionData)
        )
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
