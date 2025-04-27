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

final class IncomingASATransactionController: LedgerTransactionOperationDelegate {
    weak var delegate: IncomingASATransactionControllerDelegate?

    private let sharedDataController: SharedDataController
    private let api: ALGAPI
    private var params: TransactionParams?
    private let bannerController: BannerController?
    private let analytics: ALGAnalytics
    private let draft: IncomingASAListItem?

    private var timer: Timer?
    private var transactionData = [TransactionData]()
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
        return fromAccount?.requiresLedgerConnection() ?? false
    }
    private var fromAccount: Account?

    private var allTransactionAreSigned: Bool {
        return transactionData.first { !$0.isTransactionSigned } == nil
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
    var transactionCount: Int {
        transactionData.count
    }

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
                    title: String(localized: "title-error"),
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
                title: String(localized: "title-error"),
                message: error?.localizedDescription ?? ""
            )
            delegate?.incomingASATransactionController(
                self,
                didFailedComposing: .inapp(.sdkError(error: error))
            )
            return
        }
        
        if transactionData.isNonEmpty {
            transactionData = []
        }
        
        for (index, transaction) in transactions.enumerated() {
            let data = TransactionData(
                sender: account.address,
                unsignedTransaction: transaction,
                index: index
            )
            transactionData.append(data)
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
                title: String(localized: "title-error"),
                message: error?.localizedDescription ?? ""
            )
            delegate?.incomingASATransactionController(
                self,
                didFailedComposing: .inapp(.sdkError(error: error))
            )
            return
        }
        
        if transactionData.isNonEmpty {
            transactionData = []
        }
        
        for (index, transaction) in composedTransactions.enumerated() {
            let data = TransactionData(
                sender: account.address,
                unsignedTransaction: transaction,
                index: index
            )
            transactionData.append(data)
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
            initializeLedgerTransactionAccount()
            startTimer()

            let transaction = transactions.first
            ledgerTransactionOperation.setUnsignedTransactionData(transaction)
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
                title: String(localized: "title-error"),
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
        delegate?.incomingASATransactionControllerDidStartUploadingTransaction(self)
        
        transactionAPIConnector.uploadTransaction(transaction) {
            [weak self] transactionID, error in
            guard let self else { return }
            
            guard let transactionID else {
                self.bannerController?.presentErrorBanner(
                    title: String(localized: "title-error"),
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
            withTimeInterval: 50.0,
            repeats: false
        ) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            self.ledgerTransactionOperation.stopScan()

            self.bannerController?.presentErrorBanner(
                title: String(localized: "ble-error-connection-title"),
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
        didReceiveSignature data: Data,
        forTransactionIndex index: Int
    ) {
        signTransactionForLedgerAccount(
            with: data,
            index: index
        )
    }

    func ledgerTransactionOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation,
        didFailed error: LedgerOperationError
    ) {
        switch error {
        case .cancelled:
            bannerController?.presentErrorBanner(
                title: String(localized: "ble-error-transaction-cancelled-title"),
                message: String(localized: "ble-error-fail-sign-transaction")
            )
        case .closedApp:
            bannerController?.presentErrorBanner(
                title: String(localized: "ble-error-ledger-connection-title"),
                message: String(localized: "ble-error-ledger-connection-open-app-error")
            )
        case .unmatchedAddress:
            bannerController?.presentErrorBanner(
                title: String(localized: "ble-error-ledger-connection-title"),
                message: String(localized: "ledger-transaction-account-match-error")
            )
        case .failedToFetchAddress:
            bannerController?.presentErrorBanner(
                title: String(localized: "ble-error-transmission-title"),
                message: String(localized: "ble-error-fail-fetch-account-address")
            )
        case .failedToFetchAccountFromIndexer:
            bannerController?.presentErrorBanner(
                title: String(localized: "title-error"),
                message: String(localized: "ledger-account-fetct-error")
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
        if allTransactionAreSigned {
            delegate?.incomingASATransactionControllerDidResetLedgerOperationOnSuccess(self)
        }
    }

    func ledgerTransactionOperationDidResetOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation
    ) {
        delegate?.incomingASATransactionControllerDidResetLedgerOperation(self)
    }
}

extension IncomingASATransactionController {
    private func signTransactionForLedgerAccount(
        with data: Data,
        index: Int
    ) {
        guard let account = fromAccount else {
            return
        }
        
        func signTransaction() {
            let signer = LedgerTransactionSigner(signerAddress: account.authAddress)
            signer.eventHandler = {
                [weak self] event in
                guard let self else { return }
                
                switch event {
                case .didFailedSigning(let error):
                    resetLedgerOperationIfNeeded()
                    delegate?.incomingASATransactionController(
                        self,
                        didFailedComposing: error
                    )
                }
            }
            
            sign(
                data,
                with: signer,
                index: index
            )
        }

        if transactionData.count - 1 == index {
            signTransaction()
            completeLedgerTransaction()
            return
        }
        
        signTransaction()
        let nextTransaction = transactionData[index + 1].unsignedTransaction
        ledgerTransactionOperation.setUnsignedTransactionData(
            nextTransaction,
            transactionIndex: index + 1
        )
        ledgerTransactionOperation.startScan()
    }

    private func completeLedgerTransaction() {
        var transactionToUpload = Data()
        
        for transaction in transactionData {
            guard let signedTransaction = transaction.signedTransaction else { return }
            transactionToUpload += signedTransaction
        }
        
        uploadTransaction(transactionToUpload)
    }
}

extension IncomingASATransactionController {
    private func sign(
        _ privateData: Data?,
        with signer: TransactionSignable,
        index: Int
    ) {
        guard let unsignedTransactionData = transactionData[index].unsignedTransaction,
              let signedTransaction = signer.sign(unsignedTransactionData, with: privateData) else {
            return
        }

        transactionData[index].setSignedTransaction(signedTransaction)
        delegate?.incomingASATransactionController(self, didSignTransactionAt: index)
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
