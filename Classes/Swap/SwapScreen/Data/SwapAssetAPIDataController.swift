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
import MagpieHipo

final class SwapAssetAPIDataController: SwapAssetDataController {
    var eventHandler: EventHandler?

    let account: Account

    private(set) var userAsset: Asset
    private(set) var poolAsset: Asset?
    private(set) var slippage: Decimal = 0.5 /// <note> Default value is 0.5
    private let swapType: SwapType = .fixedInput /// <note> Swap type won't change for now.

    private let provider: SwapProvider = .tinyman /// <note> Only provider is Tinyman for now.

    private var currentSwapQuote: SwapQuote?

    private let api: ALGAPI
    private let sharedDataController: SharedDataController

    init(
        account: Account,
        userAsset: Asset,
        api: ALGAPI,
        sharedDataController: SharedDataController
    ) {
        self.account = account
        self.userAsset = userAsset
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
            loadData(draft)
        case .failed:
            /// <todo> Handle validation failure
            break
        }
    }

    private func loadData(
        _ draft: SwapQuoteDraft
    ) {
        eventHandler?(.willLoadData)

        api.getSwapQuote(draft) {
            [weak self] response in
            guard let self = self else { return }

            switch response {
            case .success(let quote):
                self.currentSwapQuote = quote
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
        self.userAsset = asset
    }

    func updatePoolAsset(
        _ asset: Asset
    ) {
        self.poolAsset = asset
    }

    func updateSlippage(
        _ slippage: Decimal
    ) {
        self.slippage = slippage
    }
}
