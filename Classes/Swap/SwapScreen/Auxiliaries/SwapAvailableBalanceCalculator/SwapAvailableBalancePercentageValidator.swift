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

//   SwapAvailableBalancePercentageCalculator.swift

import Foundation
import MagpieCore
import MagpieHipo

struct SwapAvailableBalancePercentageValidator: SwapAvailableBalanceValidator {
    var eventHandler: EventHandler?

    private let account: Account
    private let api: ALGAPI

    init(
        account: Account,
        api: ALGAPI
    ) {
        self.account = account
        self.api = api
    }

    /// <note>
    /// Returns the amount that needs to be set on the field for both success and failure cases.
    func validateAvailableSwapBalance(
        _ quote: SwapQuote,
        for asset: Asset
    ) {
        if asset.isAlgo {
            validateAvailableBalanceForAlgo(asset)
            return
        }

        validateAvailableBalanceForAsset(asset)
    }
}

extension SwapAvailableBalancePercentageValidator {
    private func validateAvailableBalanceForAlgo(
        _ asset: Asset
    ) {
        guard let algoBalanceAfterMinBalanceAndPadding = getAlgoBalanceAfterMinBalanceAndPadding() else {
            publishEvent(.failure(.insufficientAlgoBalance(0)))
            return
        }

        if algoBalanceAfterMinBalanceAndPadding == 0 {
            publishEvent(.validated(algoBalanceAfterMinBalanceAndPadding))
            return
        }

        let draft = PeraSwapFeeDraft(
            assetID: asset.id,
            amount: algoBalanceAfterMinBalanceAndPadding
        )

        api.calculatePeraSwapFee(draft) {
            response in
            switch response {
            case .success(let feeResult):
                if let peraFee = feeResult.fee {
                    let algoBalanceAfterPeraFeeResult = algoBalanceAfterMinBalanceAndPadding.subtractingReportingOverflow(peraFee)

                    if algoBalanceAfterPeraFeeResult.overflow {
                        self.publishEvent(.failure(.insufficientAlgoBalance(0)))
                        return
                    }

                    self.publishEvent(.validated(algoBalanceAfterPeraFeeResult.partialValue))
                    return
                }

                self.publishEvent(.failure(.unavailablePeraFee(nil)))
            case .failure(let apiError, let hipApiError):
                let error = HIPNetworkError(
                    apiError: apiError,
                    apiErrorDetail: hipApiError
                )
                self.publishEvent(.failure(.unavailablePeraFee(error)))
            }
        }
    }

    private func validateAvailableBalanceForAsset(
        _ asset: Asset
    ) {
        guard let assetBalance = account[asset.id]?.amount,
              assetBalance > 0 else {
            publishEvent(.failure(.insufficientAssetBalance(0)))
            return
        }

        let draft = PeraSwapFeeDraft(
            assetID: asset.id,
            amount: assetBalance
        )

        api.calculatePeraSwapFee(draft) {
            response in

            switch response {
            case .success(let feeResult):
                if let peraFee = feeResult.fee {
                    guard let algoBalanceAfterMinBalanceAndPadding = self.getAlgoBalanceAfterMinBalanceAndPadding() else {
                        self.publishEvent(.failure(.insufficientAlgoBalance(0)))
                        return
                    }

                    let algoBalanceAfterPeraFeeResult = algoBalanceAfterMinBalanceAndPadding.subtractingReportingOverflow(peraFee)

                    if algoBalanceAfterPeraFeeResult.overflow {
                        self.publishEvent(.failure(.insufficientAlgoBalance(assetBalance)))
                        return
                    }

                    self.publishEvent(.validated(assetBalance))
                    return
                }

                self.publishEvent(.failure(.unavailablePeraFee(nil)))
            case .failure(let apiError, let hipApiError):
                let error = HIPNetworkError(
                    apiError: apiError,
                    apiErrorDetail: hipApiError
                )
                self.publishEvent(.failure(.unavailablePeraFee(error)))
            }
        }
    }
}

extension SwapAvailableBalancePercentageValidator {
    private func getAlgoBalanceAfterMinBalanceAndPadding() -> UInt64? {
        let algoBalance = account.algo.amount
        let minBalance = account.calculateMinBalance()
        let algoBalanceAfterMinBalanceResult = algoBalance.subtractingReportingOverflow(minBalance)

        if algoBalanceAfterMinBalanceResult.overflow {
            return nil
        }

        let algoBalanceAfterMinBalanceAndPaddingResult =
            algoBalanceAfterMinBalanceResult
            .partialValue
            .subtractingReportingOverflow(SwapQuote.feePadding)

        if algoBalanceAfterMinBalanceAndPaddingResult.overflow {
            return nil
        }

        return algoBalanceAfterMinBalanceAndPaddingResult.partialValue
    }
}
