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

struct SwapAvailableBalancePercentageValidator: SwapAvailableBalanceValidator {
    var eventHandler: EventHandler?

    private weak var dataController: SwapAssetDataController?

    init(
        dataController: SwapAssetDataController
    ) {
        self.dataController = dataController
    }

    func validateAvailableSwapBalance(
        _ quote: SwapQuote,
        for asset: Asset
    ) {
        if asset.isAlgo {
            validateAvailableBalanceForAlgo()
            return
        }

        validateAvailableBalanceForAsset(asset)
    }
}

extension SwapAvailableBalancePercentageValidator {
    private func validateAvailableBalanceForAlgo() {
        guard let dataController = dataController,
              let algoBalanceAfterMinBalanceAndPadding = getAlgoBalanceAfterMinBalanceAndPadding() else {
            publishEvent(.failure(.insufficientAlgoBalance))
            return
        }

        if algoBalanceAfterMinBalanceAndPadding == 0 {
            publishEvent(.validated(algoBalanceAfterMinBalanceAndPadding))
            return
        }

        dataController.calculatePeraSwapFee(balance: algoBalanceAfterMinBalanceAndPadding)

        dataController.eventHandler = {
            event in
            switch event {
            case .didLoadPeraFee(let result):
                if let peraFee = result.fee {
                    let algoBalanceAfterPeraFeeResult = algoBalanceAfterMinBalanceAndPadding.subtractingReportingOverflow(peraFee)

                    if algoBalanceAfterPeraFeeResult.overflow {
                        self.publishEvent(.failure(.insufficientAlgoBalance))
                        return
                    }

                    self.publishEvent(.validated(algoBalanceAfterPeraFeeResult.partialValue))
                    return
                }

                self.publishEvent(.failure(.unavailablePeraFee(nil)))
            case .didFailToLoadPeraFee(let error):
                self.publishEvent(.failure(.unavailablePeraFee(error)))
            default: break
            }
        }
    }

    private func validateAvailableBalanceForAsset(
        _ asset: Asset
    ) {
        guard let dataController = dataController,
              let assetBalance = dataController.account[asset.id]?.amount,
              assetBalance > 0 else {
            publishEvent(.failure(.insufficientAssetBalance))
            return
        }

        dataController.calculatePeraSwapFee(balance: assetBalance)

        dataController.eventHandler = {
            event in
            switch event {
            case .didLoadPeraFee(let result):
                if let peraFee = result.fee {
                    guard let algoBalanceAfterMinBalanceAndPadding = self.getAlgoBalanceAfterMinBalanceAndPadding() else {
                        self.publishEvent(.failure(.insufficientAlgoBalance))
                        return
                    }

                    let algoBalanceAfterPeraFeeResult = algoBalanceAfterMinBalanceAndPadding.subtractingReportingOverflow(peraFee)

                    if algoBalanceAfterPeraFeeResult.overflow {
                        self.publishEvent(.failure(.insufficientAlgoBalance))
                        return
                    }

                    self.publishEvent(.validated(assetBalance))
                    return
                }

                self.publishEvent(.failure(.unavailablePeraFee(nil)))
            case .didFailToLoadPeraFee(let error):
                self.publishEvent(.failure(.unavailablePeraFee(error)))
            default: break
            }
        }
    }
}

extension SwapAvailableBalancePercentageValidator {
    private func getAlgoBalanceAfterMinBalanceAndPadding() -> UInt64? {
        guard let account = dataController?.account else { return nil }

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
