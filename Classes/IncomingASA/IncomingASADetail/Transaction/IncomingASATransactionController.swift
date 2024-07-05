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

//   IncomingASATransactionController.swift

import UIKit
import MacaroonUtils
import MagpieHipo

final class IncomingASATransactionController:
    LedgerTransactionOperationDelegate,
    TransactionSignerDelegate {
    weak var delegate: IncomingASATransactionControllerDelegate?

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

    private lazy var transactionAPIConnector = TransactionAPIConnector(
        api: api,
        sharedDataController: sharedDataController
    )
    private lazy var ledgerTransactionOperation = LedgerTransactionOperation(
        api: api,
        analytics: analytics
    )
    private var isLedgerRequiredTransaction: Bool {
        return transactionDraft?.from.requiresLedgerConnection() ?? false
    }
    private var fromAccount: Account?

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
        
        self.sharedDataController.sortedAccounts().forEach { accountHandle in
            guard accountHandle.value.address == draft.accountAddress else {return}
            self.fromAccount = accountHandle.value
        }
    }
}

extension IncomingASATransactionController {
    func getTransactionParamsAndCompleteTransaction(
        with draft: IncomingASAListItem,
        for account: Account,
        type: TransactionType
    ) {
        sharedDataController.getTransactionParams {
            [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let params):
                self.params = params
                self.composeAndCompleteTransaction(
                    params: params,
                    with: draft,
                    for: account,
                    type: type
                )
            case .failure(let error):
                self.bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: error.localizedDescription
                )
                self.delegate?.incomingASATransactionController(
                    self,
                    didFailedComposing: .inapp(.other)
                )
            }
        }
    }
}

extension IncomingASATransactionController {
    private func composeAndCompleteTransaction(
        params: TransactionParams,
        with draft: IncomingASAListItem,
        for account: Account,
        type: TransactionType
    ) {
        switch type {
        case .claim:
            composeAndSignClaimingTransaction(
                params: params,
                draft: draft,
                account: account
            )
        case .reject:
            composeAndSignRejectionTransaction(
                params: params,
                draft: draft,
                account: account
            )
        }
    }
    
    private func composeAndSignClaimingTransaction(
        params: TransactionParams,
        draft: IncomingASAListItem,
        account: Account
    ) {
        let isOptedIn = account.isOptedIn(to: draft.asset.id)
        
        let appID: Int64
        if api.isTestNet {
            appID = Environment.current.testNetARC59AppID
        } else {
            appID = Environment.current.mainNetARC59AppID
        }
        
        let transactionDraft = ARC59ClaimAssetTransactionDraft(
            from: account,
            transactionParams: params,
            inboxAccount: draft.inboxAddress,
            appID: appID,
            assetID: draft.asset.id,
            isOptedIn: isOptedIn,
            isClaimingAlgo: draft.shouldUseFundsBeforeClaiming
        )
        
        var error: NSError?
        guard let transactions = algoSDK.composeArc59ClaimAssetTxn(
            with: transactionDraft,
            error: &error
        ) else {
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: error?.localizedDescription ?? ""
            )
            delegate?.incomingASATransactionController(
                self,
                didFailedComposing: .inapp(.sdkError(error: error))
            )
            return
        }
        
        startSigningProcess(
            for: account,
            transactions: transactions
        )
    }

    private func composeAndSignRejectionTransaction(
        params: TransactionParams,
        draft: IncomingASAListItem,
        account: Account
    ) {
        let appID: Int64
        if api.isTestNet {
            appID = Environment.current.testNetARC59AppID
        } else {
            appID = Environment.current.mainNetARC59AppID
        }
        
        let transactionDraft = ARC59RejectAssetTransactionDraft(
            from: account,
            transactionParams: params,
            inboxAccount: draft.inboxAddress,
            creatorAccount: draft.asset.creator?.address,
            appID: appID,
            assetID: draft.asset.id,
            isClaimingAlgo: draft.shouldUseFundsBeforeRejecting
        )
        
        var error: NSError?
        guard let composedTransactions = algoSDK.composeArc59RejectAssetTxn(
            with: transactionDraft,
            error: &error
        ) else {
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: error?.localizedDescription ?? ""
            )
            delegate?.incomingASATransactionController(
                self,
                didFailedComposing: .inapp(.sdkError(error: error))
            )
            return
        }
        
        startSigningProcess(
            for: account,
            transactions: composedTransactions
        )
    }
    
    private func startSigningProcess(
        for account: Account,
        transactions: [Data]
    ) {
        if account.requiresLedgerConnection() {
            ledgerTransactionOperation.setUnsignedTransactionData(transactionData.unsignedTransaction)
            ledgerTransactionOperation.startScan()
        } else {
            handleStandardAccountSigning(
                account: account,
                transactions: transactions
            )
        }
    }

    private func handleStandardAccountSigning(
        account: Account?,
        transactions: [Data]
    ) {
        guard let accountAddress = account?.signerAddress,
              let privateData = api.session.privateData(for: accountAddress) else {
            delegate?.incomingASATransactionController(
                self,
                didFailedComposing: .inapp(.sdkError(error: nil))
            )
            return
        }

        var transactionToUpload = Data()
        var signError: NSError?
        
        for transaction in transactions {
            if let signedTransaction = algoSDK.sign(
                privateData,
                with: transaction,
                error: &signError
            ) {
                transactionToUpload += signedTransaction
            }
        }
        
        if let signError {
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: signError.localizedDescription
            )
            delegate?.incomingASATransactionController(
                self,
                didFailedComposing: .inapp(.sdkError(error: nil))
            )
            return
        }
        
        uploadTransaction(transactionToUpload)
    }

    private func uploadTransaction(_ transaction: Data) {
        transactionAPIConnector.uploadTransaction(transaction) {
            [weak self] transactionID, error in
            guard let self else { return }
            
            guard let transactionID else {
                self.bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: error?.localizedDescription ?? ""
                )
                
                if let error {
                    self.delegate?.incomingASATransactionController(
                        self,
                        didFailedTransaction: .network(.unexpected(error))
                    )
                }

                return
            }
            
            self.delegate?.incomingASATransactionController(
                self,
                didCompletedTransaction: transactionID
            )
        }
    }
}

extension IncomingASATransactionController {
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

        timer = Timer.scheduledTimer(
            withTimeInterval: 10.0,
            repeats: false
        ) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            self.ledgerTransactionOperation.stopScan()

            self.bannerController?.presentErrorBanner(
                title: "ble-error-connection-title".localized,
                message: ""
            )

            self.delegate?.incomingASATransactionController(
                self,
                didFailedComposing: .inapp(.ledgerConnection)
            )
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

extension IncomingASATransactionController {
    func ledgerTransactionOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation,
        didReceiveSignature data: Data
    ) {
        signTransactionForLedgerAccount(with: data)
    }

    func ledgerTransactionOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation,
        didFailed error: LedgerOperationError
    ) {
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

            delegate?.incomingASATransactionControllerDidResetLedgerOperation(self)
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
        delegate?.incomingASATransactionController(
            self,
            didRequestUserApprovalFrom: ledger
        )
    }

    func ledgerTransactionOperationDidRejected(
        _ ledgerTransactionOperation: LedgerTransactionOperation
    ) {
        delegate?.incomingASATransactionControllerDidRejectedLedgerOperation(self)
    }

    func ledgerTransactionOperationDidFinishTimingOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation
    ) {
        stopTimer()
    }

    func ledgerTransactionOperationDidResetOperationOnSuccess(
        _ ledgerTransactionOperation: LedgerTransactionOperation
    ) {
        delegate?.incomingASATransactionControllerDidResetLedgerOperationOnSuccess(self)
    }

    func ledgerTransactionOperationDidResetOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation
    ) {
        delegate?.incomingASATransactionControllerDidResetLedgerOperation(self)
    }
}

extension IncomingASATransactionController {
    private func signTransactionForLedgerAccount(with data: Data) {
        guard let account = fromAccount else {
            return
        }

        sign(data, with: LedgerTransactionSigner(signerAddress: account.authAddress))
        if transactionDraft?.fee != nil {
            completeLedgerTransaction()
        }
    }

    private func completeLedgerTransaction() {
        
    }
}

extension IncomingASATransactionController {
    private func sign(_ privateData: Data?, with signer: TransactionSigner) {
        signer.delegate = self

        guard let unsignedTransactionData = transactionData.unsignedTransaction,
              let signedTransaction = signer.sign(unsignedTransactionData, with: privateData) else {
            return
        }

        transactionData.setSignedTransaction(signedTransaction)
    }
}

extension IncomingASATransactionController {
    func transactionSigner(
        _ transactionSigner: TransactionSigner,
        didFailedSigning error: HIPTransactionError
    ) {
        resetLedgerOperationIfNeeded()
        delegate?.incomingASATransactionController(
            self,
            didFailedComposing: error
        )
    }
}

extension IncomingASATransactionController {
    private func resetLedgerOperationIfNeeded() {
        if fromAccount?.requiresLedgerConnection() ?? false {
            ledgerTransactionOperation.reset()
        }
    }
}

extension IncomingASATransactionController {
    enum TransactionType {
        case claim
        case reject
    }
}
