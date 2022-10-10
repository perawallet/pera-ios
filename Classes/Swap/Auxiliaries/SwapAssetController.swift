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

//   SwapAssetController.swift

import Foundation

protocol SwapAssetController {
    var quote: SwapQuote? { get }

    func updateQuote(_ quote: SwapQuote)
    func calculateFee()
    func prepareTransactions()
    func signTransactions()
}

final class PERASwapController: SwapAssetController {

    private(set) var quote: SwapQuote?

    private let api: ALGAPI
    private let transactionSigner: SwapTransactionSigner

    init(
        api: ALGAPI,
        transactionSigner: SwapTransactionSigner
    ) {
        self.api = api
        self.transactionSigner = transactionSigner
    }

    func updateQuote(
        _ quote: SwapQuote
    ) {
        self.quote = quote
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

    func prepareTransactions() {
        guard let quote = quote else {
            return
        }

        let draft = SwapTransactionPreparationDraft(quoteID: quote.id)

        api.prepareSwapTransactions(draft) { response in
            switch response {
            case .success(let transaction):
                break
            case .failure(let error):
                break
            }
        }
    }

    func signTransactions() {

    }

    func uploadTransactions() async {
        
        /// If the user is not opted in to tinyman, send the tinyman transaction. Wait for round.
        /// Send swap transaction. Wait for round.
        /// Send fee transaction. Wait for round.
    }

    private func waitForRound() {
        let draft = WaitRoundDraft(round: 1)
        api.waitRound(draft) { response in
            switch response {
            case .success(let round):
                break
            case .failure(let error):
                break
            }
        }
    }
}
