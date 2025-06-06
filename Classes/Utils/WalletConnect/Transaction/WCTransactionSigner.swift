// Copyright 2022-2025 Pera Wallet, LDA

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
//   WCTransactionSigner.swift

import Foundation
import MagpieHipo

final class WCTransactionSigner {
    weak var delegate: WCTransactionSignerDelegate?

    private lazy var ledgerTransactionOperation = LedgerTransactionOperation(
        api: api,
        analytics: analytics
    )

    private var timer: Timer?

    private let api: ALGAPI
    private let sharedDataController: SharedDataController
    private let analytics: ALGAnalytics
    private let hdWalletStorage: HDWalletStorable

    private var account: Account?
    private var transaction: WCTransaction?

    init(
        api: ALGAPI,
        sharedDataController: SharedDataController,
        analytics: ALGAnalytics,
        hdWalletStorage: HDWalletStorable
    ) {
        self.api = api
        self.sharedDataController = sharedDataController
        self.analytics = analytics
        self.hdWalletStorage = hdWalletStorage
    }

    func signTransaction(_ transaction: WCTransaction, for account: Account) {
        if let signerAddress = transaction.authAddress,
           let account = sharedDataController.accountCollection[signerAddress]?.value {
            signTransactionForTransactionAuthAddress(
                transaction,
                for: account
            )
            return
        }

        if account.requiresLedgerConnection() {
            signLedgerTransaction(transaction, for: account)
        } else {
            signStandardTransaction(transaction, for: account)
        }
    }

    func disonnectFromLedger() {
        ledgerTransactionOperation.disconnectFromCurrentDevice()
        ledgerTransactionOperation.stopScan()
        stopTimer()
    }
}

extension WCTransactionSigner {
    private func signTransactionForTransactionAuthAddress(
        _ transaction: WCTransaction,
        for account: Account
    ) {
        if account.hasLedgerDetail() {
            signLedgerTransaction(
                transaction,
                for: account
            )
            return
        }
        
        if account.hdWalletAddressDetail != nil {
            signTransactionForHDWalletAccount(
                transaction,
                for: account
            )
            return
        }

        let signerAddress = account.address
        guard let signature = api.session.privateData(for: signerAddress) else { return }
        
        let signer = SDKTransactionSigner()
        signer.eventHandler = {
            [weak self] event in
            guard let self else { return }
            
            switch event {
            case .didFailedSigning(let error):
                delegate?.wcTransactionSigner(
                    self,
                    didFailedWith: .api(error: error)
                )
            }
        }
        
        sign(
            signature,
            signer: signer,
            for: transaction
        )
    }
    
    private func signTransactionForHDWalletAccount(
        _ transaction: WCTransaction,
        for account: Account
    ) {
        guard let hdWalletAddressDetail = account.hdWalletAddressDetail,
              let unsignedTransaction = transaction.unparsedTransactionDetail else {
            delegate?.wcTransactionSigner(
                self,
                didFailedWith: .missingUnparsedTransactionDetail
            )
            return
        }
        
        do {
            var authWalletId = hdWalletAddressDetail.walletId
            if let authAddress = account.authAddress,
               let accountAccount = sharedDataController.accountCollection[authAddress]?.value,
               let hdWalletAddressDetail = accountAccount.hdWalletAddressDetail {
                authWalletId = hdWalletAddressDetail.walletId
            }
            
            guard let seed = try hdWalletStorage.wallet(id: authWalletId) else {
                delegate?.wcTransactionSigner(
                    self,
                    didFailedWith: .api(error: .inapp(.other))
                )
                return
            }
            
            let sdk = AlgorandSDK()
            
            var error: NSError?
            guard let rawTxn = sdk.rawTransactionToSign(
                unsignedTransaction,
                error: &error
            ) else {
                delegate?.wcTransactionSigner(
                    self,
                    didFailedWith: .api(error: .inapp(.sdkError(error: error)))
                )
                return
            }
            
            let signer = HDWalletTransactionSigner(wallet: seed)
            let signature = try signer.signTransaction(
                rawTxn,
                with: hdWalletAddressDetail
            )
            guard let signedTransaction = sdk.getSignedTransaction(
                unsignedTransaction,
                from: signature,
                for: account.authAddress,
                error: &error
            ) else {
                delegate?.wcTransactionSigner(
                    self,
                    didFailedWith: .api(error: .inapp(.sdkError(error: error)))
                )
                return
            }
            
            delegate?.wcTransactionSigner(
                self,
                didSign: transaction,
                signedTransaction: signedTransaction
            )
        } catch {
            delegate?.wcTransactionSigner(
                self,
                didFailedWith: .api(error: .inapp(.other))
            )
        }
    }
}

extension WCTransactionSigner {
    private func signLedgerTransaction(
        _ transaction: WCTransaction,
        for account: Account
    ) {
        guard let unsignedTransaction = transaction.unparsedTransactionDetail else {
            delegate?.wcTransactionSigner(self, didFailedWith: .missingUnparsedTransactionDetail)
            return
        }

        self.account = account
        self.transaction = transaction

        ledgerTransactionOperation.setTransactionAccount(account)
        ledgerTransactionOperation.setTransaction(transaction)
        ledgerTransactionOperation.delegate = self
        startTimer()
        ledgerTransactionOperation.setUnsignedTransactionData(unsignedTransaction)
        ledgerTransactionOperation.startScan()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            self.ledgerTransactionOperation.bleConnectionManager.stopScan()
            self.delegate?.wcTransactionSigner(self, didFailedWith: .ledger(error: .ledgerConnectionWarning))
            self.stopTimer()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func signStandardTransaction(
        _ transaction: WCTransaction,
        for account: Account
    ) {
        if let authAddress = account.authAddress,
           let authAccount = sharedDataController.accountCollection[authAddress]?.value,
           authAccount.isHDAccount {
            signTransactionForHDWalletAccount(
                transaction,
                for: account
            )
            return
        }
        
        if account.isHDAccount,
           !account.hasAuthAccount() {
            signTransactionForHDWalletAccount(
                transaction,
                for: account
            )
            return
        }
        
        let signerAddress = account.signerAddress
        guard let signature = api.session.privateData(for: signerAddress) else { return }
        
        let signer = SDKTransactionSigner()
        signer.eventHandler = {
            [weak self] event in
            guard let self else { return }
            
            switch event {
            case .didFailedSigning(let error):
                delegate?.wcTransactionSigner(
                    self,
                    didFailedWith: .api(error: error)
                )
            }
        }
        
        sign(
            signature,
            signer: signer,
            for: transaction
        )
    }

    private func sign(
        _ signature: Data?,
        signer: TransactionSignable,
        for transaction: WCTransaction
    ) {
        guard let unsignedTransaction = transaction.unparsedTransactionDetail else {
            delegate?.wcTransactionSigner(self, didFailedWith: .missingUnparsedTransactionDetail)
            return
        }

        guard let signedTransaction = signer.sign(unsignedTransaction, with: signature) else {
            return
        }

        delegate?.wcTransactionSigner(self, didSign: transaction, signedTransaction: signedTransaction)
    }
}

extension WCTransactionSigner: LedgerTransactionOperationDelegate {
    func ledgerTransactionOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation,
        didReceiveSignature data: Data,
        forTransactionIndex index: Int
    ) {
        guard let account,
              let transaction else {
            return
        }
        
        if let authAddress = account.authAddress,
           let authAccount = sharedDataController.accountCollection[authAddress]?.value,
           authAccount.isHDAccount {
            signTransactionForHDWalletAccount(
                transaction,
                for: account
            )
            return
        }

        let signerAddress = transaction.authAddress ?? account.authAddress
        let signer = LedgerTransactionSigner(signerAddress: signerAddress)
        signer.eventHandler = {
            [weak self] event in
            guard let self else { return }
            
            switch event {
            case .didFailedSigning(let error):
                delegate?.wcTransactionSigner(
                    self,
                    didFailedWith: .api(error: error)
                )
            }
        }
        
        sign(
            data,
            signer: signer,
            for: transaction
        )
    }

    func ledgerTransactionOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation,
        didFailed error: LedgerOperationError
    ) {
        delegate?.wcTransactionSigner(
            self,
            didFailedWith: .ledger(error: error)
        )
    }

    func ledgerTransactionOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation,
        didRequestUserApprovalFor ledger: String
    ) {
        delegate?.wcTransactionSigner(
            self,
            didRequestUserApprovalFrom: ledger
        )
    }

    func ledgerTransactionOperationDidFinishTimingOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation
    ) {
        stopTimer()
        delegate?.wcTransactionSignerDidFinishTimingOperation(self)
    }

    func ledgerTransactionOperationDidResetOperation(_ ledgerTransactionOperation: LedgerTransactionOperation) {
        delegate?.wcTransactionSignerDidResetLedgerOperation(self)
    }

    func ledgerTransactionOperationDidResetOperationOnSuccess(_ ledgerTransactionOperation: LedgerTransactionOperation) {
        delegate?.wcTransactionSignerDidResetLedgerOperationOnSuccess(self)
    }

    func ledgerTransactionOperationDidRejected(_ ledgerTransactionOperation: LedgerTransactionOperation) {
        delegate?.wcTransactionSignerDidRejectedLedgerOperation(self)
    }
}

extension WCTransactionSigner {
    enum WCSignError: Error {
        case ledger(error: LedgerOperationError)
        case api(error: HIPTransactionError)
        case missingUnparsedTransactionDetail
    }
}

protocol WCTransactionSignerDelegate: AnyObject {
    func wcTransactionSigner(_ wcTransactionSigner: WCTransactionSigner, didSign transaction: WCTransaction, signedTransaction: Data)
    func wcTransactionSigner(_ wcTransactionSigner: WCTransactionSigner, didFailedWith error: WCTransactionSigner.WCSignError)
    func wcTransactionSigner(_ wcTransactionSigner: WCTransactionSigner, didRequestUserApprovalFrom ledger: String)
    func wcTransactionSignerDidFinishTimingOperation(_ wcTransactionSigner: WCTransactionSigner)
    func wcTransactionSignerDidResetLedgerOperation(_ wcTransactionSigner: WCTransactionSigner)
    func wcTransactionSignerDidResetLedgerOperationOnSuccess(_ wcTransactionSigner: WCTransactionSigner)
    func wcTransactionSignerDidRejectedLedgerOperation(_ wcTransactionSigner: WCTransactionSigner)
}
