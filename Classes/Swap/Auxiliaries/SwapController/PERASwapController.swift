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

final class PERASwapController: SwapController {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    let account: Account
    let swapType: SwapType = .fixedInput /// <note> Swap type won't change for now.
    let provider: SwapProvider = .tinyman /// <note> Only provider is Tinyman for now.

    private(set) var userAsset: Asset
    private(set) var quote: SwapQuote?
    private(set) var poolAsset: Asset?
    private(set) var slippage: SwapSlippage = .fivePerThousand /// <note> Default value is 0.005

    private lazy var transactionMonitor = TransactionPoolMonitor(api: api)

    private let api: ALGAPI
    private let transactionSigner: SwapTransactionSigner

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
        for transactionGroup in transactionGroups where transactionGroup.purpose.isSupported {
            guard let unsignedTransactions = transactionGroup.transactions,
                  let signedTransactions = transactionGroup.signedTransactions else {
                return
            }

            let transactionIndexesToSign = signedTransactions.findIndexes(of: nil) /// Find transactions that needs to be signed
            sign(
                unsignedTransactions,
                at: transactionIndexesToSign
            )
        }
    }

    private func sign(
        _ unsignedTransactions: [Data],
        at indexes: [Int]
    ) {
        for (unsignedTransactionIndex, unsignedTransaction) in unsignedTransactions.enumerated() {
            for index in indexes {
                if unsignedTransactionIndex == index {

                    transactionSigner.eventHandler = {
                        [weak self] event in
                        guard let self = self else { return }

                        switch event {
                        case .didSignedTransaction(let signedTransaction):
                            break
                        case .didFailedSigning(let error):
                            break
                        case .didLedgerRequestUserApproval(let ledger):
                            break
                        case .didFinishTiming:
                            break
                        case .didLedgerReset:
                            break
                        case .didLedgerRejectedSigning:
                            break
                        }
                    }

                    transactionSigner.signTransaction(
                        unsignedTransaction,
                        for: account
                    )
                }
            }
        }
    }
}

extension PERASwapController {

}

extension PERASwapController {

}

extension PERASwapController {
    private func uploadTransaction(
        _ transaction: Data
    ) {
        api.sendTransaction(transaction) {
            [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let signedTransaction):
                self.monitorTransaction(signedTransaction.identifier)
            case .failure:
                break
            }
        }
    }
}

extension PERASwapController {
    private func monitorTransaction(
        _ transactionID: TxnID
    ) {
        transactionMonitor.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .willStart:
                break
            case .didCompleted:
                /// wait for 1 second
                break
            case .didFailedTransaction:
                break
            case .didFailedNetwork:
                break
            }
        }

        transactionMonitor.monitor(transactionID)
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
    enum Event {

    }
}
