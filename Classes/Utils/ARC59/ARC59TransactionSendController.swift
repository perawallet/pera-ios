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

//   ARC59TransactionSendController.swift

import Foundation
import MacaroonUtils
import MagpieCore
import MagpieExceptions
import MagpieHipo

final class ARC59TransactionSendController: NSObject {
    typealias EventHandler = (ARC59TransactionSendControllerEvent) -> Void
    typealias Error = HIPNetworkError<IndexerError>
    
    var eventHandler: EventHandler?

    private(set) var signedTransactions: [Data] = []
    
    private lazy var uploadAndMonitorOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.algorad.arc59TransactionUploadAndMonitorQueue"
        queue.qualityOfService = .userInitiated
        return queue
    }()

    private lazy var transactionMonitor = TransactionPoolMonitor(api: api)

    var account: Account
    private let api: ALGAPI
    private let transactionSigner: SwapTransactionSigner

    private lazy var sendGroupTransactionSigner = ARC59SendTransactionSigner(
        account: account,
        transactionSigner: transactionSigner
    )

    init(
        account: Account,
        api: ALGAPI,
        transactionSigner: SwapTransactionSigner
    ) {
        self.account = account
        self.api = api
        self.transactionSigner = transactionSigner
    }
}

extension ARC59TransactionSendController {
    func signTransactionGroups(_ transactions: [[Data]]) {
        sendGroupTransactionSigner.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didSignTransaction:
                self.publishEvent(.didSignTransaction)
            case .didCompleteSigningTransactions(let transactions):
                self.signedTransactions = transactions
                self.publishEvent(.didSignAllTransactions)
                self.uploadTransactionsAndWaitForConfirmation()
            case .didFailSigning(error: let error):
                self.publishEvent(.didFailSigning(error: error))
            case .didLedgerRequestUserApproval(let ledger):
                self.publishEvent(
                    .didLedgerRequestUserApproval(
                        ledger: ledger,
                        transactions: transactions
                    )
                )
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
        
        var mappedTransactions: [Int: [Data]] = [:]
        for (groupIndex, groupTransactions) in transactions.enumerated() {
            mappedTransactions[groupIndex] = groupTransactions
        }

        sendGroupTransactionSigner.signGroupTransactions(
            mappedTransactions,
            shouldUpdateUnsignedTransactions: true
        )
    }

    func clearTransactions() {
        signedTransactions = []
        sendGroupTransactionSigner.clearTransactions()
    }

    func disconnectFromLedger() {
        sendGroupTransactionSigner.disconnectFromLedger()
    }
}

extension ARC59TransactionSendController {
    private func uploadTransactionsAndWaitForConfirmation() {
        var operations: [Operation] = []

        for transaction in signedTransactions {
            let isLastTransaction = signedTransactions.last == transaction
            let transactionUploadAndWaitOperation = TransactionUploadAndWaitOperation(
                signedTransaction: transaction,
                waitingTimeAfterTransactionConfirmed: isLastTransaction ? 0.0 : 1.0,
                transactionMonitor: transactionMonitor,
                api: api,
                shouldReturnSuccessWhenCompleted: isLastTransaction
            )

            transactionUploadAndWaitOperation.eventHandler = {
                [weak self] event in
                guard let self = self else { return }

                switch event {
                case .didCompleteTransactionOnTheNode(let id):
                    self.publishEvent(.didCompleteTransactionOnTheNode(id))
                case .didFailTransaction(let id):
                    self.cancelAllOperations()
                    self.publishEvent(.didFailTransaction(id))
                case .didFailNetwork(let error):
                    self.cancelAllOperations()
                    self.publishEvent(.didFailNetwork(error))
                case .didCancelTransaction:
                    self.cancelAllOperations()
                    self.publishEvent(.didCancelTransaction)
                }
            }

            operations.append(transactionUploadAndWaitOperation)
        }
        
        addOperationDependencies(&operations)
        uploadAndMonitorOperationQueue.addOperations(
            operations,
            waitUntilFinished: false
        )
    }

    private func cancelAllOperations() {
        uploadAndMonitorOperationQueue.cancelAllOperations()
    }
}

extension ARC59TransactionSendController {
    private func addOperationDependencies(_ operations: inout [Operation]) {
        var previousOperation: Operation?
        operations.forEach { operation in
            if let anOperation = previousOperation {
                operation.addDependency(anOperation)
            }

            previousOperation = operation
        }
    }
}

extension ARC59TransactionSendController {
    private func publishEvent(_ event: ARC59TransactionSendControllerEvent) {
        asyncMain {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(event)
        }
    }
}

enum ARC59TransactionSendControllerEvent {
    case didSignTransaction
    case didSignAllTransactions
    case didCompleteTransactionOnTheNode(TxnID)
    case didFailTransaction(TxnID)
    case didFailNetwork(ARC59TransactionSendController.Error)
    case didCancelTransaction
    case didFailSigning(error: SwapTransactionSigner.SignError)
    case didLedgerRequestUserApproval(ledger: String, transactions: [[Data]])
    case didFinishTiming
    case didLedgerReset
    case didLedgerResetOnSuccess
    case didLedgerRejectSigning
}
