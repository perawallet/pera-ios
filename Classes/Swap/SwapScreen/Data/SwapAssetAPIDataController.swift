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

//   SwapAssetAPIDataController.swift

import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo

final class SwapAssetAPIDataController: SwapAssetDataController {
    var eventHandler: EventHandler?

    var account: Account {
        return swapController.account
    }
    var userAsset: Asset {
        return swapController.userAsset
    }
    var poolAsset: Asset? {
        return swapController.poolAsset
    }
    var slippage: SwapSlippage {
        return swapController.slippage
    }

    private var quote: SwapQuote? {
        return swapController.quote
    }
    private var provider: SwapProvider {
        return swapController.provider
    }
    private var swapType: SwapType {
        return swapController.swapType
    }

    private var currentQuoteEndpoint: EndpointOperatable?
    private lazy var quoteThrottler = Throttler(intervalInSeconds: 0.8)

    private let swapController: SwapController
    private let api: ALGAPI
    private let sharedDataController: SharedDataController

    init(
        swapController: SwapController,
        api: ALGAPI,
        sharedDataController: SharedDataController
    ) {
        self.swapController = swapController
        self.api = api
        self.sharedDataController = sharedDataController
    }
}

extension SwapAssetAPIDataController {
    func loadData(
        swapAmount: Decimal
    ) {
        guard let deviceID = api.session.authenticatedUser?.getDeviceId(on: api.network),
              let poolAssetID = poolAsset?.id else {
            return
        }

        let draft = SwapQuoteDraft(
            providers: [provider],
            swapperAddress: account.address,
            type: swapType,
            deviceID: deviceID,
            assetInID: userAsset.id,
            assetOutID: poolAssetID,
            amount: swapAmount,
            slippage: slippage
        )

        let validationResult = draft.validate()

        switch validationResult {
        case .validated:
            quoteThrottler.performNext {
                [weak self] in
                guard let self = self else { return }

                self.loadData(draft)
            }
        case .failed(let reason):
            eventHandler?(.didFailValidation(reason))
        }
    }

    private func loadData(
        _ draft: SwapQuoteDraft
    ) {
        if currentQuoteEndpoint != nil {
            currentQuoteEndpoint = nil
            currentQuoteEndpoint?.cancel()
        }

        eventHandler?(.willLoadData)

        currentQuoteEndpoint = api.getSwapQuote(draft) {
            [weak self] response in
            guard let self = self else { return }

            self.currentQuoteEndpoint = nil

            switch response {
            case .success(let quoteList):
                guard let quote = quoteList.results[safe: 0] else { return }

                self.swapController.updateQuote(quote)
                self.eventHandler?(.didLoadData(quote))
            case .failure(let apiError, let hipApiError):
                let error = HIPNetworkError(
                    apiError: apiError,
                    apiErrorDetail: hipApiError
                )
                self.eventHandler?(.didFailToLoadData(error))
            }
        }
    }
}

extension SwapAssetAPIDataController {
    func updateUserAsset(
        _ asset: Asset
    ) {
        swapController.updateUserAsset(asset)
    }

    func updatePoolAsset(
        _ asset: Asset
    ) {
        swapController.updatePoolAsset(asset)
    }

    func updateSlippage(
        _ slippage: SwapSlippage
    ) {
        swapController.updateSlippage(slippage)
    }
}
