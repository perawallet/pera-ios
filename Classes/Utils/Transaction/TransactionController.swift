// Copyright 2022 Pera Wallet, LDA

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

import MagpieHipo
import UIKit

final class TransactionController {
    weak var delegate: TransactionControllerDelegate?

    private(set) var currentTransactionType: TransactionType?
    
    var ledgerTansactionCount: Int {
        let senderAddresses = transactions.map { $0.sender }
        if senderAddresses.isEmpty {
            return 0
        }
        
        let accounts = senderAddresses.compactMap { sharedDataController.accountCollection[$0]?.value }
        return accounts.filter { $0.requiresLedgerConnection() }.count
    }

    private lazy var ledgerTransactionOperation = LedgerTransactionOperation(
        api: api,
        analytics: analytics
    )

    private lazy var transactionAPIConnector = TransactionAPIConnector(
        api: api, 
        sharedDataController: sharedDataController
    )
    
    private lazy var transactionSignatureValidator = TransactionSignatureValidator(
        session: api.session,
        sharedDataController: sharedDataController
    )

    private var requiresLedgerConnection: Bool {
        return senderAccountForLedger != nil
    }
    
    private var params: TransactionParams?
    private var timer: Timer?
    private var transactions = [TransactionData]()
    private var transactionDraft: TransactionSendDraft?

    private var api: ALGAPI
    private let sharedDataController: SharedDataController
    private let bannerController: BannerController?
    private let analytics: ALGAnalytics
    
    init(
        api: ALGAPI,
        sharedDataController: SharedDataController,
        bannerController: BannerController?,
        analytics: ALGAnalytics
    ) {
        self.api = api
        self.sharedDataController = sharedDataController
        self.bannerController = bannerController
        self.analytics = analytics
    }
}

extension TransactionController {
    var senderAccountForLedger: Account? {
        let senderAddresses = transactions.map { $0.sender }
        if senderAddresses.isEmpty {
            return nil
        }
        
        let accounts = senderAddresses.compactMap { sharedDataController.accountCollection[$0]?.value }
        return accounts.first { $0.requiresLedgerConnection() }
    }

    var assetTransactionDraft: AssetTransactionSendDraft? {
        return transactionDraft as? AssetTransactionSendDraft
    }
    
    var keyRegTransactionDraft: KeyRegTransactionSendDraft? {
        return transactionDraft as? KeyRegTransactionSendDraft
    }

    var algosTransactionDraft: AlgosTransactionSendDraft? {
        return transactionDraft as? AlgosTransactionSendDraft
    }

    var rekeyTransactionDraft: RekeyTransactionSendDraft? {
        return transactionDraft as? RekeyTransactionSendDraft
    }

    private var isTransactionSigned: Bool {
        return transactions.allSatisfy { $0.signedTransaction != nil }
    }
}

extension TransactionController {
    func canSignTransaction(for account: Account) -> Bool {
        let validation = transactionSignatureValidator.validateTxnSignature(account)
        
        switch validation {
        case .success:
            return true
        case .failure(let error):
            bannerController?.present(error)
            return false
        }
    }
    
    func setTransactionDraft(_ transactionDraft: TransactionSendDraft) {
        self.transactionDraft = transactionDraft
        
        /// <note>
        /// We need to update the ledger information of a rekeyed account so that we can use ledger information
        /// of its auth account while signing the transaction.
        var account = transactionDraft.from
        updateLedgerDetailOfRekeyedAccountIfNeeded(of: &account)
        self.transactionDraft?.from = account
    }
    
    private func updateLedgerDetailOfRekeyedAccountIfNeeded(of account: inout Account) {
        guard let authAddress = account.authAddress,
              let authAccount = sharedDataController.accountCollection[authAddress],
              let ledgerDetail = authAccount.value.ledgerDetail else {
            return
        }
        
        account.addRekeyDetail(
            ledgerDetail,
            for: authAddress
        )
    }
    
    func stopBLEScan() {
        if !requiresLedgerConnection {
            return
        }

        ledgerTransactionOperation.disconnectFromCurrentDevice()
        ledgerTransactionOperation.stopScan()
    }

    func startTimer() {
        if !requiresLedgerConnection {
            return
        }

        ledgerTransactionOperation.delegate = self

        timer = Timer.scheduledTimer(
            withTimeInterval: 20.0,
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

            self.delegate?.transactionController(
                self,
                didFailedComposing: .inapp(.ledgerConnection)
            )
            self.stopTimer()
        }
    }

    func stopTimer() {
        if !requiresLedgerConnection {
            return
        }

        timer?.invalidate()
        timer = nil
    }

    func initializeLedgerTransactionAccount() {
        if !requiresLedgerConnection {
            return
        }

        if let account = senderAccountForLedger {
            ledgerTransactionOperation.setTransactionAccount(account)
        }
    }
}

extension TransactionController {
    func getTransactionParamsAndComposeTransactionData(for transactionType: TransactionType) {
        currentTransactionType = transactionType

        transactionAPIConnector.getTransactionParams { result in
            switch result {
            case .success(let params):
                self.params = params
                self.composeTransactionData(
                    for: transactionType,
                    index: 0
                )
            case .failure:
                self.resetLedgerOperationIfNeeded()
                self.transactions.removeAll()

                self.delegate?.transactionController(
                    self,
                    didFailedComposing: .network(.connection(.init(reason: .unexpected(.unknown))))
                )
            }
        }
    }
    
    func uploadTransaction(_ completion: EmptyHandler? = nil) {
        var transactionToUpload = Data()
        for transaction in transactions {
            guard let signedTransaction = transaction.signedTransaction else {
                continue
            }
            
            transactionToUpload.append(signedTransaction)
        }

        transactionAPIConnector.uploadTransaction(transactionToUpload) { transactionId, error in
            guard let id = transactionId else {
                self.resetLedgerOperationIfNeeded()
                self.logLedgerTransactionNonAcceptanceError()
                if let error = error {
                    self.delegate?.transactionController(
                        self,
                        didFailedTransaction: .network(.unexpected(error))
                    )
                }
                self.transactions.removeAll()
                return
            }

            completion?()
            self.delegate?.transactionController(
                self,
                didCompletedTransaction: id
            )
        }
    }
}

extension TransactionController {
    private func composeTransactionData(
        for transactionType: TransactionType,
        initialSize: Int? = nil,
        index: Int
    ) {
        guard let params else { return }
        
        switch transactionType {
        case .algo:
            guard let algosTransactionDraft else { return }
            
            let builder = AlgoTransactionDataBuilder(
                params: params,
                draft: algosTransactionDraft,
                initialSize: initialSize
            )
            builder.eventHandler = {
                [weak self] event in
                guard let self else { return }
                
                switch event {
                case .didFailedComposing(let error):
                    handleTransactionComposingError(error)
                }
            }
            composeTransactionData(from: builder)
        case .optIn:
            guard let assetTransactionDraft else { return }
            
            let builder = OptInTransactionDataBuilder(
                params: params,
                draft: assetTransactionDraft
            )
            builder.eventHandler = {
                [weak self] event in
                guard let self else { return }
                
                switch event {
                case .didFailedComposing(let error):
                    handleTransactionComposingError(error)
                }
            }
            composeTransactionData(from: builder)
        case .optOut:
            guard let assetTransactionDraft else { return }
            
            let builder = OptOutTransactionDataBuilder(
                params: params,
                draft: assetTransactionDraft
            )
            builder.eventHandler = {
                [weak self] event in
                guard let self else { return }
                
                switch event {
                case .didFailedComposing(let error):
                    handleTransactionComposingError(error)
                }
            }
            composeTransactionData(from: builder)
        case .asset:
            guard let assetTransactionDraft else { return }
            
            let builder = AssetTransactionDataBuilder(
                params: params,
                draft: assetTransactionDraft
            )
            builder.eventHandler = {
                [weak self] event in
                guard let self else { return }
                
                switch event {
                case .didFailedComposing(let error):
                    handleTransactionComposingError(error)
                }
            }
            composeTransactionData(from: builder)
        case .rekey:
            guard let rekeyTransactionDraft else { return }
            
            let builder = RekeyTransactionDataBuilder(
                params: params,
                draft: rekeyTransactionDraft
            )
            builder.eventHandler = {
                [weak self] event in
                guard let self else { return }
                
                switch event {
                case .didFailedComposing(let error):
                    handleTransactionComposingError(error)
                }
            }
            composeTransactionData(from: builder)
        case .optInAndSend:
            guard let assetTransactionDraft else { return }
            
            let builder = OptInAndSendTransactionDataBuilder(
                sharedDataController: sharedDataController,
                params: params,
                draft: assetTransactionDraft
            )
            builder.eventHandler = {
                [weak self] event in
                guard let self else { return }
                
                switch event {
                case .didFailedComposing(let error):
                    handleTransactionComposingError(error)
                }
            }
            composeTransactionData(from: builder)
        case .keyreg:
            guard let keyRegTransactionDraft else { return }
            
            let builder = KeyRegTransactionDataBuilder(
                params: params,
                draft: keyRegTransactionDraft
            )
            builder.eventHandler = {
                [weak self] event in
                guard let self else { return }
                
                switch event {
                case .didFailedComposing(let error):
                    handleTransactionComposingError(error)
                }
            }
            composeTransactionData(from: builder)
        }

        let isUnsignedTransactionComposed = transactions.allSatisfy { $0.isUnsignedTransactionComposed }
        if isUnsignedTransactionComposed {
            startSigningProcess(
                for: transactionType,
                index: index
            )
        }
    }

    private func composeTransactionData(from builder: TransactionDataBuildable) {
        guard let txnItems = builder.composeData() else {
            handleMinimumAmountErrorIfNeeded(from: builder)
            resetLedgerOperationIfNeeded()
            transactions.removeAll()
            return
        }

        updateTransactionAmount(from: builder)
        
        for item in txnItems {
            let transaction = TransactionData(
                sender: item.sender,
                unsignedTransaction: item.transaction,
                index: transactions.count
            )
            transactions.append(transaction)
        }
    }

    private func handleMinimumAmountErrorIfNeeded(from builder: TransactionDataBuildable) {
        if let builder = builder as? AlgoTransactionDataBuilder,
           let minimumAccountBalance = builder.minimumAccountBalance,
           builder.calculatedTransactionAmount.unwrap(or: 0).isBelowZero {
            delegate?.transactionController(
                self,
                didFailedComposing: .inapp(TransactionError.minimumAmount(amount: minimumAccountBalance))
            )
        }
    }

    private func updateTransactionAmount(from builder: TransactionDataBuildable) {
        if let builder = builder as? AlgoTransactionDataBuilder {
            transactionDraft?.amount = builder.calculatedTransactionAmount?.toAlgos
        }
    }
}

extension TransactionController {
    private func startSigningProcess(
        for transactionType: TransactionType,
        index: Int
    ) {
        guard let transaction = transactions[safe: index],
              let account = sharedDataController.accountCollection[transaction.sender]?.value else {
                  return
        }

        if account.requiresLedgerConnection() {
            initializeLedgerTransactionAccount()
            startTimer()
            ledgerTransactionOperation.setUnsignedTransactionData(
                transaction.unsignedTransaction,
                transactionIndex: index
            )
            ledgerTransactionOperation.startScan()
        } else {
            handleStandardAccountSigning(
                with: transactionType,
                index: index
            )
        }
    }
    
    private func handleStandardAccountSigning(
        with transactionType: TransactionType,
        index: Int
    ) {
        signTransactionForStandardAccount(index: index)

        if isTransactionSigned {
            calculateTransactionFee(
                for: transactionType,
                index: index
            )
            if transactionDraft?.fee == nil {
                return
            }
            
            if transactionType == .algo {
                completeAlgosTransaction(index: index)
            } else if transactionType == .keyreg {
                completeKeyRegTranscation()
            } else {
                completeAssetTransaction(for: transactionType)
            }
        } else {
            startSigningProcess(
                for: transactionType,
                index: index + 1
            )
        }
    }

    private func signTransactionForStandardAccount(index: Int) {
        guard let accountAddress = transactions[safe: index]?.sender else {
            return
        }
        
        let address = sharedDataController.accountCollection[accountAddress]?.value.authAddress ?? accountAddress
        guard let privateData = api.session.privateData(for: address) else { return }

        let signer = SDKTransactionSigner()
        signer.eventHandler = {
            [weak self] event in
            guard let self else { return }
            
            switch event {
            case .didFailedSigning(let error):
                handleTransactionComposingError(error)
            }
        }
        
        sign(
            privateData,
            with: signer,
            index: index
        )
    }

    private func sign(
        _ privateData: Data?,
        with signer: TransactionSignable,
        index: Int
    ) {
        guard let unsignedTransactionData = transactions[index].unsignedTransaction,
              let signedTransaction = signer.sign(unsignedTransactionData, with: privateData) else {
            return
        }

        transactions[index].setSignedTransaction(signedTransaction)
    }
}

extension TransactionController: LedgerTransactionOperationDelegate {
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

    private func signTransactionForLedgerAccount(
        with data: Data,
        index: Int
    ) {
        guard let transactionType = currentTransactionType,
              let senderAddress = transactions[safe: index]?.sender,
              var account = sharedDataController.accountCollection[senderAddress]?.value else {
            return
        }
        
        updateLedgerDetailOfRekeyedAccountIfNeeded(of: &account)
        
        let signer = LedgerTransactionSigner(signerAddress: account.authAddress)
        signer.eventHandler = {
            [weak self] event in
            guard let self else { return }
            
            switch event {
            case .didFailedSigning(let error):
                handleTransactionComposingError(error)
            }
        }

        sign(
            data,
            with: signer,
            index: index
        )
        
        calculateTransactionFee(
            for: transactionType,
            index: index
        )
        if transactionDraft?.fee != nil {
            if isTransactionSigned {
                completeLedgerTransaction(
                    for: transactionType,
                    index: index
                )
            } else {
                startSigningProcess(
                    for: transactionType,
                    index: index + 1
                )
            }
        }
    }

    private func completeLedgerTransaction(
        for transactionType: TransactionType,
        index: Int
    ) {
        if transactionType == .algo {
            completeAlgosTransaction(index: index)
        } else if transactionType == .rekey {
            completeRekeyTransaction()
        } else if transactionType == .keyreg {
            completeKeyRegTranscation()
        } else {
            completeAssetTransaction(for: transactionType)
        }
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

            delegate?.transactionControllerDidResetLedgerOperation(self)
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
        delegate?.transactionController(self, didRequestUserApprovalFrom: ledger)
    }

    func ledgerTransactionOperationDidRejected(_ ledgerTransactionOperation: LedgerTransactionOperation) {
        delegate?.transactionControllerDidRejectedLedgerOperation(self)
    }

    func ledgerTransactionOperationDidFinishTimingOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation
    ) {
        stopTimer()
    }

    func ledgerTransactionOperationDidResetOperationOnSuccess(
        _ ledgerTransactionOperation: LedgerTransactionOperation
    ) {
        delegate?.transactionControllerDidResetLedgerOperationOnSuccess(self)
    }

    func ledgerTransactionOperationDidResetOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation
    ) {
        delegate?.transactionControllerDidResetLedgerOperation(self)
    }
}

extension TransactionController {
    private func calculateTransactionFee(
        for transactionType: TransactionType,
        index: Int
    ) {
        let feeCalculator = TransactionFeeCalculator(
            transactionDraft: transactionDraft,
            transactionData: transactions[index],
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
    private func completeAlgosTransaction(index: Int) {
        guard let calculatedFee = transactionDraft?.fee,
              let params = params,
              let signedTransactionData = transactions[index].signedTransaction else {
            return
        }
        
        /// Re-sign transaction if the calculated fee is not matching with the projected fee
        if params.getProjectedTransactionFee(from: signedTransactionData.count) != calculatedFee {
            composeTransactionData(
                for: .algo,
                initialSize: signedTransactionData.count,
                index: index
            )
        } else {
            delegate?.transactionController(
                self,
                didComposedTransactionDataFor: self.algosTransactionDraft
            )
        }
    }
    
    private func completeKeyRegTranscation() {
        uploadTransaction {
            self.delegate?.transactionController(
                self,
                didComposedTransactionDataFor: self.keyRegTransactionDraft
            )
        }
    }

    private func completeAssetTransaction(for transactionType: TransactionType) {
        /// Asset addition and removal actions do not have approve part, so transaction should be completed here.
        if transactionType == .asset || transactionType == .optInAndSend {
            delegate?.transactionController(
                self,
                didComposedTransactionDataFor: self.assetTransactionDraft
            )
        } else {
            uploadTransaction {
                self.delegate?.transactionController(
                    self,
                    didComposedTransactionDataFor: self.assetTransactionDraft
                )
            }

        }
    }

    private func completeRekeyTransaction() {
        uploadTransaction {
            self.delegate?.transactionController(
                self,
                didComposedTransactionDataFor: self.rekeyTransactionDraft
            )
        }
    }
}

extension TransactionController {
    private func handleTransactionComposingError(_ error: HIPTransactionError) {
        resetLedgerOperationIfNeeded()
        transactions.removeAll()
        delegate?.transactionController(self, didFailedComposing: error)
    }
}

extension TransactionController: TransactionFeeCalculatorDelegate {
    func transactionFeeCalculator(
        _ transactionFeeCalculator: TransactionFeeCalculator,
        didFailedWith minimumAmount: UInt64
    ) {
        handleTransactionComposingError(.inapp(TransactionError.minimumAmount(amount: minimumAmount)))
    }
}

extension TransactionController {
    private func resetLedgerOperationIfNeeded() {
        if senderAccountForLedger != nil {
            ledgerTransactionOperation.reset()
        }
    }
}

extension TransactionController {
    private func logLedgerTransactionNonAcceptanceError() {
        guard let account = senderAccountForLedger else {
            return
        }
        
        analytics.record(
            .nonAcceptanceLedgerTransaction(
                account: account,
                transactionData: transactions[0]
            )
        )
    }
}

extension TransactionController {
    enum TransactionType {
        case algo
        case asset
        case optIn
        case optOut
        case optInAndSend
        case rekey
        case keyreg
    }
}
