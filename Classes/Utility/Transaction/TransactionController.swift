// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  transactionController.swift

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

    private var isLedgerRequiredTransaction: Bool {
        return transactionDraft?.from.requiresLedgerConnection() ?? false
    }
    
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
        if !isLedgerRequiredTransaction {
            return
        }

        ledgerTransactionOperation.disconnectFromCurrentDevice()
        ledgerTransactionOperation.stopScan()
    }

    func startTimer() {
        if !isLedgerRequiredTransaction {
            return
        }

        ledgerTransactionOperation.delegate = self
        ledgerTransactionOperation.startTimer()
    }

    func stopTimer() {
        if !isLedgerRequiredTransaction {
            return
        }

        ledgerTransactionOperation.stopTimer()
    }

    func initializeLedgerTransactionAccount() {
        if !isLedgerRequiredTransaction {
            return
        }

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

        if transactionData.isUnsignedTransactionComposed {
            startSigningProcess(for: transactionType)
        }
    }

    private func composeTransactionData(from builder: TransactionDataBuilder) {
        builder.delegate = self

        guard let data = builder.composeData() else {
            handleMinimumAmountErrorIfNeeded(from: builder)
            resetLedgerOperationIfNeeded()
            return
        }

        updateTransactionAmount(from: builder)
        transactionData.setUnsignedTransaction(data)
    }

    private func handleMinimumAmountErrorIfNeeded(from builder: TransactionDataBuilder) {
        if let builder = builder as? SendAlgosTransactionDataBuilder,
           let minimumAccountBalance = builder.minimumAccountBalance,
           builder.calculatedTransactionAmount.unwrap(or: 0).isBelowZero {
            delegate?.transactionController(self, didFailedComposing: .inapp(TransactionError.minimumAmount(amount: minimumAccountBalance)))
        }
    }

    private func updateTransactionAmount(from builder: TransactionDataBuilder) {
        if let builder = builder as? SendAlgosTransactionDataBuilder {
            transactionDraft?.amount = builder.calculatedTransactionAmount?.toAlgos
        }
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
            if transactionDraft?.fee == nil {
                return
            }
            
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
        if transactionDraft?.fee != nil {
            completeLedgerTransaction(for: transactionType)
        }
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

    func ledgerTransactionOperation(_ ledgerTransactionOperation: LedgerTransactionOperation, didFailed error: LedgerOperationError) {
        switch error {
        case .cancelled:
            NotificationBanner.showError(
                "ble-error-transaction-cancelled-title".localized,
                message: "ble-error-fail-sign-transaction".localized
            )
        case .closedApp:
            NotificationBanner.showError(
                "ble-error-ledger-connection-title".localized,
                message: "ble-error-ledger-connection-open-app-error".localized
            )
        default:
            break
        }
    }
}

extension TransactionController {
    private func calculateTransactionFee(for transactionType: TransactionType) {
        let feeCalculator = TransactionFeeCalculator(
            transactionDraft: transactionDraft,
            transactionData: transactionData,
            params: params
        )
        feeCalculator.delegate = self
        let fee = feeCalculator.calculate(for: transactionType)
        if fee != nil {
            self.transactionDraft?.fee = fee
        }
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
