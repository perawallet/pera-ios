// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   IncomingASAsDetailScreenAPIDataController.swift

import UIKit
import MacaroonUtils
import MagpieHipo

protocol IncomingASAsDetailScreenAPIDataControllerDelegate: AnyObject {
    func incomingASAsDetailScreenAPIDataController(_ incomingASAsDetailScreenAPIDataController: IncomingASAsDetailScreenAPIDataController, didCompletedTransaction transactionId: TransactionID?)
    func incomingASAsDetailScreenAPIDataController(_ incomingASAsDetailScreenAPIDataController: IncomingASAsDetailScreenAPIDataController, didFailedComposing error: HIPTransactionError)
    func incomingASAsDetailScreenAPIDataControllerDidResetLedgerOperation(_ incomingASAsDetailScreenAPIDataController: IncomingASAsDetailScreenAPIDataController)
    func incomingASAsDetailScreenAPIDataControllerDidRejectedLedgerOperation(_ incomingASAsDetailScreenAPIDataController: IncomingASAsDetailScreenAPIDataController)
    func incomingASAsDetailScreenAPIDataControllerDidResetLedgerOperationOnSuccess(_ incomingASAsDetailScreenAPIDataController: IncomingASAsDetailScreenAPIDataController)
    func incomingASAsDetailScreenAPIDataController(_ incomingASAsDetailScreenAPIDataController: IncomingASAsDetailScreenAPIDataController, didRequestUserApprovalFrom ledger: String)
    func incomingASAsDetailScreenAPIDataController(_ incomingASAsDetailScreenAPIDataController: IncomingASAsDetailScreenAPIDataController, didComposedTransactionDataFor draft: TransactionSendDraft?)
    func incomingASAsDetailScreenAPIDataController(_ incomingASAsDetailScreenAPIDataController: IncomingASAsDetailScreenAPIDataController, didFailedTransaction error: HIPTransactionError)
}
// Provide default implementations for the protocol methods
extension IncomingASAsDetailScreenAPIDataControllerDelegate {
    func incomingASAsDetailScreenAPIDataController(_ incomingASAsDetailScreenAPIDataController: IncomingASAsDetailScreenAPIDataController, didFailedComposing error: HIPTransactionError) {}
    func incomingASAsDetailScreenAPIDataControllerDidResetLedgerOperation(_ incomingASAsDetailScreenAPIDataController: IncomingASAsDetailScreenAPIDataController) {}
    func incomingASAsDetailScreenAPIDataControllerDidRejectedLedgerOperation(_ incomingASAsDetailScreenAPIDataController: IncomingASAsDetailScreenAPIDataController) {}
    func incomingASAsDetailScreenAPIDataControllerDidResetLedgerOperationOnSuccess(_ incomingASAsDetailScreenAPIDataController: IncomingASAsDetailScreenAPIDataController) {}
    func incomingASAsDetailScreenAPIDataController(_ incomingASAsDetailScreenAPIDataController: IncomingASAsDetailScreenAPIDataController, didRequestUserApprovalFrom ledger: String) {}
    func incomingASAsDetailScreenAPIDataController(_ incomingASAsDetailScreenAPIDataController: IncomingASAsDetailScreenAPIDataController, didComposedTransactionDataFor draft: TransactionSendDraft?) {}
    func incomingASAsDetailScreenAPIDataController(_ incomingASAsDetailScreenAPIDataController: IncomingASAsDetailScreenAPIDataController, didFailedTransaction error: HIPTransactionError) {}
}

final class IncomingASAsDetailScreenAPIDataController:
    SharedDataControllerObserver {
    

    weak var delegate: IncomingASAsDetailScreenAPIDataControllerDelegate?

    private(set) var currentTransactionType: TransactionType?

    private let sharedDataController: SharedDataController
    private let api: ALGAPI
    private var params: TransactionParams?
    private let bannerController: BannerController?
    private let analytics: ALGAnalytics
    private var transactionDraft: TransactionSendDraft?
    private let draft: IncomingASAListItem?

    private var timer: Timer?
    private let transactionData = TransactionData()
    private var algoSDK = AlgorandSDK()

    private lazy var transactionAPIConnector = TransactionAPIConnector(api: api, sharedDataController: sharedDataController)
    private lazy var ledgerTransactionOperation =
        LedgerTransactionOperation(api: api, analytics: analytics)
    private var isLedgerRequiredTransaction: Bool {
        return transactionDraft?.from.requiresLedgerConnection() ?? false
    }
    private var fromAccount: Account?

    var assetTransactionDraft: AssetTransactionSendDraft? {
        return transactionDraft as? AssetTransactionSendDraft
    }
    
    var algosTransactionDraft: AlgosTransactionSendDraft? {
        return transactionDraft as? AlgosTransactionSendDraft
    }

    var rekeyTransactionDraft: RekeyTransactionSendDraft? {
        return transactionDraft as? RekeyTransactionSendDraft
    }

    private var isTransactionSigned: Bool {
        return transactionData.signedTransaction != nil
    }
    
    init(
        sharedDataController: SharedDataController,
        api: ALGAPI,
        bannerController: BannerController?,
        analytics: ALGAnalytics,
        draft: IncomingASAListItem
    ) {
        self.sharedDataController = sharedDataController
        self.api = api
        self.bannerController = bannerController
        self.analytics = analytics
        self.draft = draft
        
        self.fetchTransactionParams()
        self.sharedDataController.sortedAccounts().forEach { accountHandle in
            guard accountHandle.value.address == draft.accountAddress else {return}
            self.fromAccount = accountHandle.value
        }
    }

    deinit {
        sharedDataController.remove(self)
    }
}

extension IncomingASAsDetailScreenAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {}
}

extension IncomingASAsDetailScreenAPIDataController {
    private func fetchTransactionParams() {
        sharedDataController.getTransactionParams(isCacheEnabled: true) { [weak self] paramsResult in
            guard let self else {
                return
            }
            switch paramsResult {
            case .success(let params):
                self.params = params
            case .failure(let error):
                self.bannerController?.presentErrorBanner(title: "title-error".localized, message: error.localizedDescription)
            }
        }
    }
}

extension IncomingASAsDetailScreenAPIDataController {
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

        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            self.ledgerTransactionOperation.stopScan()

            self.bannerController?.presentErrorBanner(
                title: "ble-error-connection-title".localized,
                message: ""
            )

            self.delegate?.incomingASAsDetailScreenAPIDataController(self, didFailedComposing: .inapp(.ledgerConnection))
            self.stopTimer()
        }
    }

    func stopTimer() {
        if !isLedgerRequiredTransaction {
            return
        }

        timer?.invalidate()
        timer = nil
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

extension IncomingASAsDetailScreenAPIDataController: LedgerTransactionOperationDelegate {
    func ledgerTransactionOperation(_ ledgerTransactionOperation: LedgerTransactionOperation, didReceiveSignature data: Data) {
        signTransactionForLedgerAccount(with: data)
    }

    private func signTransactionForLedgerAccount(with data: Data) {
        guard let transactionType = currentTransactionType,
              let account = fromAccount else {
            return
        }

        sign(data, with: LedgerTransactionSigner(signerAddress: account.authAddress))
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
            bannerController?.presentErrorBanner(
                title: "ble-error-transaction-cancelled-title".localized,
                message: "ble-error-fail-sign-transaction".localized
            )
        case .closedApp:
            bannerController?.presentErrorBanner(
                title: "ble-error-ledger-connection-title".localized,
                message: "ble-error-ledger-connection-open-app-error".localized
            )
        case .unmatchedAddress:
            bannerController?.presentErrorBanner(
                title: "ble-error-ledger-connection-title".localized,
                message: "ledger-transaction-account-match-error".localized
            )
        case .failedToFetchAddress:
            bannerController?.presentErrorBanner(
                title: "ble-error-transmission-title".localized,
                message: "ble-error-fail-fetch-account-address".localized
            )
        case .failedToFetchAccountFromIndexer:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "ledger-account-fetct-error".localized
            )
        case .failedBLEConnectionError(let state):
            guard let errorTitle = state.errorDescription.title,
                  let errorSubtitle = state.errorDescription.subtitle else {
                return
            }

            bannerController?.presentErrorBanner(
                title: errorTitle,
                message: errorSubtitle
            )

            delegate?.incomingASAsDetailScreenAPIDataControllerDidResetLedgerOperation(self)
        case let .custom(title, message):
            bannerController?.presentErrorBanner(
                title: title,
                message: message
            )
        default:
            break
        }
    }

    func ledgerTransactionOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation,
        didRequestUserApprovalFor ledger: String
    ) {
        delegate?.incomingASAsDetailScreenAPIDataController(self, didRequestUserApprovalFrom: ledger)
    }

    func ledgerTransactionOperationDidRejected(_ ledgerTransactionOperation: LedgerTransactionOperation) {
        delegate?.incomingASAsDetailScreenAPIDataControllerDidRejectedLedgerOperation(self)
    }

    func ledgerTransactionOperationDidFinishTimingOperation(_ ledgerTransactionOperation: LedgerTransactionOperation) {
        stopTimer()
    }

    func ledgerTransactionOperationDidResetOperationOnSuccess(_ ledgerTransactionOperation: LedgerTransactionOperation) {
        delegate?.incomingASAsDetailScreenAPIDataControllerDidResetLedgerOperationOnSuccess(self)
    }

    func ledgerTransactionOperationDidResetOperation(_ ledgerTransactionOperation: LedgerTransactionOperation) {
        delegate?.incomingASAsDetailScreenAPIDataControllerDidResetLedgerOperation(self)
    }
}

extension IncomingASAsDetailScreenAPIDataController {
    enum TransactionType {
        case algosTransaction
        case assetTransaction
        case assetAddition
        case assetRemoval
        case rekey
    }
}

extension IncomingASAsDetailScreenAPIDataController {
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
            delegate?.incomingASAsDetailScreenAPIDataController(self, didComposedTransactionDataFor: self.algosTransactionDraft)
        }
    }

    private func completeAssetTransaction(for transactionType: TransactionType) {
        /// Asset addition and removal actions do not have approve part, so transaction should be completed here.
        if transactionType != .assetTransaction {
            uploadTransaction {
                self.delegate?.incomingASAsDetailScreenAPIDataController(self, didComposedTransactionDataFor: self.assetTransactionDraft)
            }
        } else {
            delegate?.incomingASAsDetailScreenAPIDataController(self, didComposedTransactionDataFor: self.assetTransactionDraft)
        }
    }

    private func completeRekeyTransaction() {
        uploadTransaction {
            self.delegate?.incomingASAsDetailScreenAPIDataController(self, didComposedTransactionDataFor: self.rekeyTransactionDraft)
        }
    }
}

extension IncomingASAsDetailScreenAPIDataController {
    private func handleStandardAccountSigning(with transactionType: TransactionType) {
        signTransactionForStandardAccount()
        
        if isTransactionSigned {
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
        guard let accountAddress = fromAccount?.signerAddress,
              let privateData = api.session.privateData(for: accountAddress) else {
            return
        }

        sign(privateData, with: SDKTransactionSigner())
    }
    // signer = AlgoSDK
    private func sign(_ privateData: Data?, with signer: TransactionSigner) {
        signer.delegate = self

        guard let unsignedTransactionData = transactionData.unsignedTransaction,
              let signedTransaction = signer.sign(unsignedTransactionData, with: privateData) else {
            return
        }

        transactionData.setSignedTransaction(signedTransaction)
    }
    
    func uploadTransaction(with completion: EmptyHandler? = nil) {
        guard let transactionData = transactionData.signedTransaction else {
            return
        }
        // MARK: - use transactionAPIConnector for upload
        transactionAPIConnector.uploadTransaction(transactionData) { transactionId, error in
            guard let id = transactionId else {
                self.resetLedgerOperationIfNeeded()
                self.logLedgerTransactionNonAcceptanceError()
                if let error = error {
                    self.delegate?.incomingASAsDetailScreenAPIDataController(self, didFailedTransaction: .network(.unexpected(error)))
                }
                return
            }

            completion?()
            self.delegate?.incomingASAsDetailScreenAPIDataController(self, didCompletedTransaction: id)
        }
    }

}

extension IncomingASAsDetailScreenAPIDataController: TransactionSignerDelegate {
    func transactionSigner(_ transactionSigner: TransactionSigner, didFailedSigning error: HIPTransactionError) {
        handleTransactionComposingError(error)
    }
}

extension IncomingASAsDetailScreenAPIDataController {
    private func logLedgerTransactionNonAcceptanceError() {
        guard let account = fromAccount,
              account.requiresLedgerConnection() else {
            return
        }
        
        analytics.record(
            .nonAcceptanceLedgerTransaction(account: account, transactionData: transactionData)
        )
    }
}


extension IncomingASAsDetailScreenAPIDataController {
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
            delegate?.incomingASAsDetailScreenAPIDataController(self, didFailedComposing: .inapp(TransactionError.minimumAmount(amount: minimumAccountBalance)))
        }
    }

    private func updateTransactionAmount(from builder: TransactionDataBuilder) {
        if let builder = builder as? SendAlgosTransactionDataBuilder {
            transactionDraft?.amount = builder.calculatedTransactionAmount?.toAlgos
        }
    }
    // TODO:  check here for sign from algo sdk
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

extension IncomingASAsDetailScreenAPIDataController: TransactionDataBuilderDelegate {
    func transactionDataBuilder(_ transactionDataBuilder: TransactionDataBuilder, didFailedComposing error: HIPTransactionError) {
        handleTransactionComposingError(error)
    }

    private func handleTransactionComposingError(_ error: HIPTransactionError) {
        resetLedgerOperationIfNeeded()
        delegate?.incomingASAsDetailScreenAPIDataController(self, didFailedComposing: error)
    }
}

extension IncomingASAsDetailScreenAPIDataController {
    private func resetLedgerOperationIfNeeded() {
        if fromAccount?.requiresLedgerConnection() ?? false {
            ledgerTransactionOperation.reset()
        }
    }
}
/// standard accounts flow tested and working
extension IncomingASAsDetailScreenAPIDataController {

    func composeArc59ClaimAssetTxn(with draft: IncomingASAListItem, account: Account) {
        guard let transactionParams = params else { return }
        let isOptedIn = account.isOptedIn(to: draft.asset.id)

        let arc59ClaimAssetTransactionDraft = ARC59ClaimAssetTransactionDraft(
            from: account,
            transactionParams: transactionParams,
            inboxAccount: draft.inboxAddress,
            appID: 655494101,
            assetID: draft.asset.id,
            isOptedIn: isOptedIn,
            secretKey: nil
        )
        
        var error: NSError?

        if let dataList = algoSDK.composeArc59ClaimAssetTxn(
            with: arc59ClaimAssetTransactionDraft,
            error: &error
        ) {
            startSigningProcess(for: account, dataList: dataList)
        }
        if let error {
            self.bannerController?.presentErrorBanner(title: "title-error".localized, message: error.localizedDescription)
        }
    }

    func composeArc59RejectAssetTxn(with draft: IncomingASAListItem, account: Account) {
        guard let transactionParams = params else { return }
        var error: NSError?

        let arc59RejectAssetTransactionDraft = ARC59RejectAssetTransactionDraft(
            from: account,
            transactionParams: transactionParams,
            inboxAccount: draft.inboxAddress,
            creatorAccount: draft.asset.creator?.address,
            appID: 655494101,
            assetID: draft.asset.id,
            secretKey: nil
        )
        
        if let data = algoSDK.composeArc59RejectAssetTxn(
            with: arc59RejectAssetTransactionDraft,
            error: &error
        ) {
            startSigningProcess(for: account, dataList: [data])
        }
        
        if let error {
            self.bannerController?.presentErrorBanner(title: "title-error".localized, message: error.localizedDescription)
        }
    }
    
    private func startSigningProcess(for account: Account, dataList: [Data]) {
        if account.requiresLedgerConnection() {
            ledgerTransactionOperation.setUnsignedTransactionData(transactionData.unsignedTransaction)
            ledgerTransactionOperation.startScan()
        } else {
            handleStandardAccountSigning(account: account, dataList: dataList)
        }
    }

    private func handleStandardAccountSigning(account: Account?, dataList: [Data]) {
        guard let accountAddress = account?.signerAddress,
              let privateData = api.session.privateData(for: accountAddress) else {
            return
        }

        var signedTxn = Data()
        var signError: NSError?
        for data in dataList {
            if let data = algoSDK.sign(privateData, with: data, error: &signError) {
                signedTxn += data
            }
        }
        
        if let signError {
            self.bannerController?.presentErrorBanner(title: "title-error".localized, message: signError.localizedDescription)
            return
        }
        
        uploadTransaction(with: signedTxn)
    }

    
    private func uploadTransaction(with transactionData: Data) {
        transactionAPIConnector.uploadTransaction(transactionData) { transactionId, error in
            guard transactionId != nil else {
                if let error = error {
                    self.bannerController?.presentErrorBanner(title: "title-error".localized, message: error.localizedDescription)
                }
                return
            }
            self.delegate?.incomingASAsDetailScreenAPIDataController(self, didCompletedTransaction: transactionId)
        }
    }
}
