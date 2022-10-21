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

//   PERASwapController.swift

import Foundation
import MacaroonUtils

final class PERASwapController: SwapController {
    var eventHandler: EventHandler?

    let account: Account
    let swapType: SwapType = .fixedInput /// <note> Swap type won't change for now.
    let provider: SwapProvider = .tinyman /// <note> Only provider is Tinyman for now.

    private(set) var userAsset: Asset
    private(set) var quote: SwapQuote?
    private(set) var poolAsset: Asset?
    private(set) var slippage: SwapSlippage = .fivePerThousand /// <note> Default value is 0.005

    private lazy var uploadAndMonitorOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.algorad.swapTransactionUploadAndMonitorQueue"
        queue.qualityOfService = .userInitiated
        return queue
    }()

    private lazy var transactionMonitor = TransactionPoolMonitor(api: api)

    private let api: ALGAPI
    private let transactionSigner: SwapTransactionSigner

    private var signedTransactions = [Data]()

    private lazy var swapTransactionSigningManager = SwapTransactionSigningManager(
        account: account,
        transactionSigner: transactionSigner
    )

    init(
        account: Account,
        userAsset: Asset,
        api: ALGAPI,
        transactionSigner: SwapTransactionSigner
    ) {
        self.account = account
        self.userAsset = userAsset
        self.api = api
        self.transactionSigner = transactionSigner
    }
}

extension PERASwapController {
    func signTransactions(
        _ transactionGroups: [SwapTransactionGroup]
    ) {
        swapTransactionSigningManager.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didSignTransaction:
                self.publishEvent(.didSignTransaction)
            case .didCompleteSigningTransactions(let transactions):
                self.uploadTransactionsAndWaitForConfirmation(transactions)
            case .didFailSigning(error: let error):
                self.publishEvent(.didFailSigning(error: error))
            case .didLedgerRequestUserApproval(let ledger):
                self.publishEvent(
                    .didLedgerRequestUserApproval(
                        ledger: ledger,
                        transactionGroups: transactionGroups
                    )
                )
            case .didFinishTiming:
                self.publishEvent(.didFinishTiming)
            case .didLedgerReset:
                self.publishEvent(.didLedgerReset)
            case .didLedgerRejectSigning:
                self.publishEvent(.didLedgerRejectSigning)
            }
        }

        swapTransactionSigningManager.signTransactions(transactionGroups)
    }
}

extension PERASwapController {
    private func uploadTransactionsAndWaitForConfirmation(
        _ transactions: [Data]
    ) {
        var operations: [Operation] = []

        for transaction in transactions {
            let isLastTransaction = transactions.last == transaction
            let transactionUploadAndWaitOperation = TransactionUploadAndWaitOperation(
                signedTransaction: transaction,
                waitingTimeAfterTransactionConfirmed: isLastTransaction ? 0.0 : 1.0,
                transactionMonitor: transactionMonitor,
                api: api
            )

            transactionUploadAndWaitOperation.eventHandler = {
                [weak self] event in
                guard let self = self else { return }

                switch event {
                case .didFailTransaction(let id):
                    self.publishEvent(.didFailTransaction(id))
                case .didFailNetwork(let error):
                    self.publishEvent(.didFailNetwork(error))
                case .didCancelTransaction:
                    self.publishEvent(.didCancelTransaction)
                }
            }

            operations.append(transactionUploadAndWaitOperation)
        }

        let completionOperation = BlockOperation {
            [weak self] in
            guard let self = self else { return }

            self.publishEvent(.didCompleteSwap)
        }

        operations.append(completionOperation)
        addOperationDependencies(&operations)
        uploadAndMonitorOperationQueue.addOperations(
            operations,
            waitUntilFinished: false
        )
    }

    private func addOperationDependencies(
        _ operations: inout [Operation]
    ) {
        var previousOperation: Operation?
        operations.forEach { operation in
            if let anOperation = previousOperation {
                operation.addDependency(anOperation)
            }

            previousOperation = operation
        }
    }
}

extension PERASwapController {
    func updateQuote(
        _ quote: SwapQuote
    ) {
        self.quote = quote
    }

    func updateSlippage(
        _ slippage: SwapSlippage
    ) {
        self.slippage = slippage
    }

    func updateUserAsset(
        _ asset: Asset
    ) {
        self.userAsset = asset
    }

    func updatePoolAsset(
        _ asset: Asset
    ) {
        self.poolAsset = asset
    }
}

extension PERASwapController {
    private func publishEvent(
        _ event: SwapControllerEvent
    ) {
        asyncMain {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(event)
        }
    }
}
