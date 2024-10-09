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

//   ARC59SendTransactionSigner.swift

import Foundation

final class ARC59SendTransactionSigner: NSObject {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    private var allTransactionsSigned: Bool {
        let signedTransactions = signedTransactionGroups.flatMap{ $0.value }
        return signedTransactions.count == totalTransactionCountToBeSigned
    }

    private let account: Account
    private let transactionSigner: SwapTransactionSigner

    private var unsignedTransactionGroups: [Int: [Data]] = [:]
    private var signedTransactionGroups: [Int: [Data]] = [:]
    private var totalTransactionCountToBeSigned = 0

    init(
        account: Account,
        transactionSigner: SwapTransactionSigner
    ) {
        self.account = account
        self.transactionSigner = transactionSigner
    }

    func signGroupTransactions(
        _ unsignedTransactionGroups: [Int: [Data]],
        shouldUpdateUnsignedTransactions: Bool
    ) {
        self.unsignedTransactionGroups = unsignedTransactionGroups
        if shouldUpdateUnsignedTransactions {
            self.totalTransactionCountToBeSigned = unsignedTransactionGroups.flatMap{ $0.value }.count
        }

        for (groupIndex, transactionGroup) in unsignedTransactionGroups {
            for unsignedTransaction in transactionGroup {
                sign(unsignedTransaction, at: groupIndex)
                
                /// <note>
                /// If an account requires a Ledger connection, one transaction should be signed at a time
                /// since the signing process happens on the Ledger one by one.
                if account.requiresLedgerConnection() {
                    return
                }
            }
        }
    }

    func clearTransactions()  {
        unsignedTransactionGroups = [:]
        signedTransactionGroups = [:]
    }

    func disconnectFromLedger() {
        transactionSigner.disonnectFromLedger()
    }
}

extension ARC59SendTransactionSigner {
    private func sign(
        _ unsignedTransaction: Data,
        at groupIndex: Int
    ) {
        transactionSigner.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didSignTransaction(let signedTransaction):
                if signedTransactionGroups[groupIndex] != nil {
                    self.signedTransactionGroups[groupIndex]?.append(signedTransaction)
                } else {
                    self.signedTransactionGroups[groupIndex] = [signedTransaction]
                }
                
                self.publishEvent(.didSignTransaction)

                if self.allTransactionsSigned {
                    self.publishTransactions()
                    return
                }

                if self.account.requiresLedgerConnection() {
                    guard let transactionsInGroup = self.unsignedTransactionGroups[groupIndex] else {
                        return
                    }
                    
                    let remainingUnsignedTransactions = Array(transactionsInGroup.dropFirst())
                    var copiedUnsignedTransactions = self.unsignedTransactionGroups
                    copiedUnsignedTransactions[groupIndex] = remainingUnsignedTransactions
                    self.signGroupTransactions(
                        copiedUnsignedTransactions,
                        shouldUpdateUnsignedTransactions: false
                    )
                }
            case .didFailSigning(let error):
                self.publishEvent(.didFailSigning(error: error))
            case .didLedgerRequestUserApproval(let ledger):
                self.publishEvent(.didLedgerRequestUserApproval(ledger: ledger))
            case .didFinishTiming:
                self.publishEvent(.didFinishTiming)
            case .didLedgerReset:
                self.publishEvent(.didLedgerReset)
            case .didLedgerResetOnSuccess:
                self.publishEvent(.didLedgerResetOnSuccess)
            case .didLedgerRejectSigning:
                self.publishEvent(.didLedgerRejectSigning)
            }
        }

        transactionSigner.signTransaction(
            unsignedTransaction,
            for: account
        )
    }

    private func publishTransactions() {
        var transactionsToUpload = [Data]()
        let atomicTransactionLimit = 1

        for (_, signedTransactionGroup) in signedTransactionGroups {
            /// Add transactions that are not in a group
            if signedTransactionGroup.count == atomicTransactionLimit {
                let signedTransaction = signedTransactionGroup.compactMap { $0 }
                transactionsToUpload.append(contentsOf: signedTransaction)
                continue
            }

            /// Combine signed group transactions as a single transaction to upload
            var signedFullGroupTransaction = Data()
            for signedTransaction in signedTransactionGroup {
                signedFullGroupTransaction += signedTransaction
            }

            transactionsToUpload.append(signedFullGroupTransaction)
        }

        publishEvent(.didCompleteSigningTransactions(transactionsToUpload))
    }
}

extension ARC59SendTransactionSigner {
    private func publishEvent(_ event: Event) {
        eventHandler?(event)
    }
}

extension ARC59SendTransactionSigner {
    enum Event {
        case didSignTransaction
        case didCompleteSigningTransactions([Data])
        case didFailSigning(error: SwapTransactionSigner.SignError)
        case didLedgerRequestUserApproval(ledger: String)
        case didFinishTiming
        case didLedgerReset
        case didLedgerResetOnSuccess
        case didLedgerRejectSigning
    }
}
