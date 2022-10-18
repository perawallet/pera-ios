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

    func calculateFee() {
        let draft = PeraSwapFeeDraft(assetID: 1, amount: 1)
        api.calculatePeraSwapFee(draft) { response in
            switch response {
            case .success(let feeResult):
                break
            case .failure(let error):
                break
            }
        }
    }

    func prepareTransactions(
        _ transactions: [SwapTransactionGroup]
    ) {
        guard let quote = quote else { return }

        for transaction in transactions {

        }
    }

    func signTransactions() {

    }

    func uploadTransactions() {

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
