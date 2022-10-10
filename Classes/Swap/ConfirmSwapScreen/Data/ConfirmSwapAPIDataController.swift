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

//   ConfirmSwapAPIDataController.swift

import Foundation
import MagpieHipo

final class ConfirmSwapAPIDataController: ConfirmSwapDataController {
    var eventHandler: EventHandler?

    let account: Account
    private(set) var quote: SwapQuote
    private let api: ALGAPI

    init(
        account: Account,
        quote: SwapQuote,
        api: ALGAPI
    ) {
        self.account = account
        self.quote = quote
        self.api = api
    }
}

extension ConfirmSwapAPIDataController {
    func updateSlippage(
        _ slippage: Decimal
    ) {
        /// <todo> Will be implemented with the main structure.
    }

    func confirmSwap() {
        /// <todo> Will be implemented with the main structure.
        let draft = SwapTransactionPreparationDraft(quoteID: quote.id)
        api.prepareSwapTransactions(draft) {
            [weak self] response in
            guard let self = self else { return }

            switch response {
            case .success(let swapTransaction):
                break
            case .failure(let error):
                break
            }
        }
    }
}
