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

//   ConfirmSwapAPIDataController.swift

import Foundation
import MagpieHipo
import pera_wallet_core

final class ConfirmSwapAPIDataController: ConfirmSwapDataController {
    var eventHandler: EventHandler?

    var account: Account {
        return swapController.account
    }
    var quote: SwapQuote {
        return swapController.quote!
    }

    private var swapController: SwapController
    private let api: ALGAPI
    private let featureFlagService: FeatureFlagServicing

    init(
        swapController: SwapController,
        api: ALGAPI,
        featureFlagService: FeatureFlagServicing
    ) {
        self.swapController = swapController
        self.api = api
        self.featureFlagService = featureFlagService
    }
}

extension ConfirmSwapAPIDataController {
    func updateSlippageTolerancePercentage(percentage: SwapSlippageTolerancePercentage?) {
        guard let deviceID = api.session.authenticatedUser?.getDeviceId(on: api.network),
              let poolAssetID = swapController.poolAsset?.id,
              let swapAmount = swapController.quote?.amountIn else {
            return
        }

        let slippage = percentage?.value
        let draft = SwapQuoteDraft(
            providers: featureFlagService.isEnabled(.swapV2Enabled) ? swapController.providersV2.map(\.name) : swapController.providers.map { $0.rawValue },
            swapperAddress: account.address,
            type: swapController.swapType,
            deviceID: deviceID,
            assetInID: swapController.userAsset.id,
            assetOutID: poolAssetID,
            amount: swapAmount,
            slippage: slippage
        )

        eventHandler?(.willUpdateSlippage)

        api.getSwapQuote(draft) {
            [weak self] response in
            guard let self = self else { return }

            switch response {
            case .success(let quoteList):
                guard let quote = quoteList.results[safe: 0] else { return }

                self.swapController.slippage = slippage
                self.swapController.quote = quote
                self.eventHandler?(.didUpdateSlippage(quote))
            case .failure(let apiError, let hipApiError):
                let error = HIPNetworkError(
                    apiError: apiError,
                    apiErrorDetail: hipApiError
                )
                self.eventHandler?(.didFailToUpdateSlippage(error))
            }
        }
    }

    func confirmSwap() {
        eventHandler?(.willPrepareTransactions)

        let draft = SwapTransactionPreparationDraft(quoteID: quote.id)
        api.prepareSwapTransactions(draft) {
            [weak self] response in
            guard let self = self else { return }

            switch response {
            case .success(let transactionPreparation):
                self.eventHandler?(.didPrepareTransactions(transactionPreparation))
            case .failure(let apiError, let hipApiError):
                let error = HIPNetworkError(
                    apiError: apiError,
                    apiErrorDetail: hipApiError
                )
                self.eventHandler?(.didFailToPrepareTransactions(error))
            }
        }
    }
}
