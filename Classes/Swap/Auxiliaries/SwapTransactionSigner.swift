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

//   SwapTransactionSigner.swift

import Foundation

final class SwapTransactionSigner:
    LedgerTransactionOperationDelegate,
    TransactionSignerDelegate {

    weak var delegate: WCTransactionSignerDelegate?

    private lazy var ledgerTransactionOperation = LedgerTransactionOperation(
        api: api,
        analytics: analytics
    )

    private var timer: Timer?

    private let api: ALGAPI
    private let analytics: ALGAnalytics

    private var account: Account?

    init(
        api: ALGAPI,
        analytics: ALGAnalytics
    ) {
        self.api = api
        self.analytics = analytics
    }

    func signTransaction(for account: Account) {
        if account.requiresLedgerConnection() {
            signLedgerTransaction(for: account)
        } else {
            signStandardTransaction(for: account)
        }
    }

    func disonnectFromLedger() {
        ledgerTransactionOperation.disconnectFromCurrentDevice()
        ledgerTransactionOperation.stopScan()
        stopTimer()
    }
}

extension SwapTransactionSigner {
    private func signLedgerTransaction(
        for account: Account
    ) {
        self.account = account

        ledgerTransactionOperation.setTransactionAccount(account)
        ledgerTransactionOperation.delegate = self
        startTimer()
        // ledgerTransactionOperation.setUnsignedTransactionData(unsignedTransaction)

        // Needs a bit delay since the bluetooth scanning for the first time is working initially
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.ledgerTransactionOperation.startScan()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            self.ledgerTransactionOperation.bleConnectionManager.stopScan()
            /// Return event error
            self.stopTimer()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func signStandardTransaction(
        for account: Account
    ) {

    }

    private func sign(
        signer: TransactionSigner
    ) {
        signer.delegate = self

        /// Get unsigned transaction
        /// Sign transaction
        /// Return event
    }
}

extension SwapTransactionSigner {
    func ledgerTransactionOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation,
        didReceiveSignature data: Data
    ) {
        guard let account = account else {
            return
        }

        sign(signer: LedgerTransactionSigner(account: account))
    }

    func ledgerTransactionOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation,
        didFailed error: LedgerOperationError
    ) {
        /// Return error
    }

    func ledgerTransactionOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation,
        didRequestUserApprovalFor ledger: String
    ) {
        /// Return approval
    }

    func ledgerTransactionOperationDidFinishTimingOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation
    ) {
        stopTimer()
        /// Return error
    }

    func ledgerTransactionOperationDidResetOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation
    ) {
        /// Return error
    }

    func ledgerTransactionOperationDidRejected(
        _ ledgerTransactionOperation: LedgerTransactionOperation
    ) {
        /// Return error
    }
}

extension SwapTransactionSigner {
    func transactionSigner(
        _ transactionSigner: TransactionSigner,
        didFailedSigning error: HIPTransactionError
    ) {
        /// Return error
    }
}

extension SwapTransactionSigner {
    enum SignError: Error {
        case ledger(error: LedgerOperationError)
        case api(error: HIPTransactionError)
    }
}

extension SwapTransactionSigner {
    enum Event {

    }
}
