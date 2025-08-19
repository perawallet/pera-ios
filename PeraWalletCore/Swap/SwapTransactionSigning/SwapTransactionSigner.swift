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

//   SwapTransactionSigner.swift

import Foundation

public final class SwapTransactionSigner: LedgerTransactionOperationDelegate {
    public typealias EventHandler = (Event) -> Void

    public var eventHandler: EventHandler?

    private lazy var ledgerTransactionOperation = LedgerTransactionOperation(
        api: api,
        analytics: analytics
    )

    private var timer: Timer?

    private let api: ALGAPI
    private let analytics: ALGAnalytics
    private let hdWalletStorage: HDWalletStorable
    private let sharedDataController: SharedDataController

    private var account: Account?
    private var unsignedTransaction: Data?

    public init(
        api: ALGAPI,
        analytics: ALGAnalytics,
        hdWalletStorage: HDWalletStorable,
        sharedDataController: SharedDataController
    ) {
        self.api = api
        self.analytics = analytics
        self.hdWalletStorage = hdWalletStorage
        self.sharedDataController = sharedDataController
    }

    public func signTransaction(
        _ unsignedTransaction: Data,
        for account: Account
    ) {
        if account.requiresLedgerConnection() {
            signLedgerTransaction(
                unsignedTransaction,
                for: account
            )
        } else {
            signStandardTransaction(
                unsignedTransaction,
                for: account
            )
        }
    }

    public func disonnectFromLedger() {
        ledgerTransactionOperation.disconnectFromCurrentDevice()
        ledgerTransactionOperation.stopScan()
        stopTimer()
    }
}

extension SwapTransactionSigner {
    private func signLedgerTransaction(
        _ unsignedTransaction: Data,
        for account: Account
    ) {
        self.unsignedTransaction = unsignedTransaction
        self.account = account

        ledgerTransactionOperation.setTransactionAccount(account)
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
            self.eventHandler?(.didFailSigning(error: .ledger(error: .ledgerConnectionWarning)))
            self.stopTimer()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func signStandardTransaction(
        _ unsignedTransaction: Data,
        for account: Account
    ) {
        self.unsignedTransaction = unsignedTransaction
        self.account = account
        
        if let authAddress = account.authAddress,
           let authAccount = sharedDataController.accountCollection[authAddress]?.value,
           authAccount.isHDAccount {
            signTransactionForHDWalletAccount(
                unsignedTransaction,
                for: account
            )
            return
        }
        
        if account.isHDAccount,
           !account.hasAuthAccount() {
            signTransactionForHDWalletAccount(
                unsignedTransaction,
                for: account
            )
            return
        }
        
        guard let signature = api.session.privateData(for: account.signerAddress) else {
            return
        }

        let signer = SDKTransactionSigner()
        signer.eventHandler = {
            [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .didFailedSigning(let error):
                eventHandler?(.didFailSigning(error: .api(error: error)))
            }
        }
        
        sign(
            signature: signature,
            signer: signer,
            unsignedTransaction: unsignedTransaction
        )
    }

    private func sign(
        signature: Data?,
        signer: TransactionSignable,
        unsignedTransaction: Data
    ) {
        guard let signedTransaction = signer.sign(
            unsignedTransaction,
            with: signature
        ) else {
            return
        }

        eventHandler?(.didSignTransaction(signedTransaction: signedTransaction))
    }
    
    private func signTransactionForHDWalletAccount(
        _ unsignedTransaction: Data,
        for account: Account
    ) {
        do {
            var hdWalletAddressDetail = account.hdWalletAddressDetail
            var authWalletId = hdWalletAddressDetail?.walletId
            
            if let authAddress = account.authAddress,
               let authAccount = sharedDataController.accountCollection[authAddress]?.value,
               let authHDWalletAddressDetail = authAccount.hdWalletAddressDetail {
                hdWalletAddressDetail = authHDWalletAddressDetail
                authWalletId = authHDWalletAddressDetail.walletId
            }
            
            guard let hdWalletAddressDetail,
                  let authWalletId else {
                return
            }
            
            guard let seed = try hdWalletStorage.wallet(id: authWalletId) else {
                return
            }
            
            let sdk = AlgorandSDK()
            
            var error: NSError?
            guard let rawTxn = sdk.rawTransactionToSign(
                unsignedTransaction,
                error: &error
            ) else {
                eventHandler?(
                    .didFailSigning(
                        error: .api(error: HIPTransactionError.inapp(.sdkError(error: error)))
                    )
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
                eventHandler?(
                    .didFailSigning(
                        error: .api(error: HIPTransactionError.inapp(.sdkError(error: error)))
                    )
                )
                return
            }
                    
            eventHandler?(.didSignTransaction(signedTransaction: signedTransaction))
        } catch {
            eventHandler?(
                .didFailSigning(
                    error: .api(error: HIPTransactionError.inapp(.other))
                )
            )
        }
    }
}

extension SwapTransactionSigner {
    public func ledgerTransactionOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation,
        didReceiveSignature data: Data,
        forTransactionIndex index: Int
    ) {
        if let account {
            if let authAddress = account.authAddress,
               let authAccount = sharedDataController.accountCollection[authAddress]?.value,
               authAccount.isHDAccount {
                signTransactionForHDWalletAccount(
                    unsignedTransaction!,
                    for: account
                )
                return
            }
            
            let signer = LedgerTransactionSigner(signerAddress: account.authAddress)
            signer.eventHandler = {
                [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .didFailedSigning(let error):
                    eventHandler?(.didFailSigning(error: .api(error: error)))
                }
            }

            sign(
                signature: data,
                signer: signer,
                unsignedTransaction: unsignedTransaction!
            )
        }
    }

    public func ledgerTransactionOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation,
        didFailed error: LedgerOperationError
    ) {
        eventHandler?(.didFailSigning(error: .ledger(error: error)))
    }

    public func ledgerTransactionOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation,
        didRequestUserApprovalFor ledger: String
    ) {
        eventHandler?(.didLedgerRequestUserApproval(ledger: ledger))
    }

    public func ledgerTransactionOperationDidFinishTimingOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation
    ) {
        stopTimer()
        eventHandler?(.didFinishTiming)
    }

    public func ledgerTransactionOperationDidResetOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation
    ) {
        eventHandler?(.didLedgerReset)
    }

    public func ledgerTransactionOperationDidResetOperationOnSuccess(
        _ ledgerTransactionOperation: LedgerTransactionOperation
    ) {
        eventHandler?(.didLedgerResetOnSuccess)
    }

    public func ledgerTransactionOperationDidRejected(
        _ ledgerTransactionOperation: LedgerTransactionOperation
    ) {
        eventHandler?(.didLedgerRejectSigning)
    }
}

extension SwapTransactionSigner {
    public enum SignError: Error {
        case ledger(error: LedgerOperationError)
        case api(error: HIPTransactionError)
    }
}

extension SwapTransactionSigner {
    public enum Event {
        case didSignTransaction(signedTransaction: Data)
        case didFailSigning(error: SignError)
        case didLedgerRequestUserApproval(ledger: String)
        case didFinishTiming
        case didLedgerReset
        case didLedgerResetOnSuccess
        case didLedgerRejectSigning
    }
}
