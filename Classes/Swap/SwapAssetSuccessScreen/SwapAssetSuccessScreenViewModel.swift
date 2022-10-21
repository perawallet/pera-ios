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

//   SwapAssetSuccessScreenViewModel.swift

import MacaroonUIKit
import UIKit

struct SwapAssetSuccessScreenViewModel {
    private(set) var title: TextProvider?
    private(set) var detail: TextProvider?

    init(
        _ quote: SwapQuote
    ) {
        bindTitle(quote)
        bindDetail(quote)
    }
}

extension SwapAssetSuccessScreenViewModel {
    mutating func bindTitle(
        _ quote: SwapQuote
    ) {
        guard let assetIn = quote.assetIn,
              let assetOut = quote.assetOut else {
            return
        }

        let assetInDisplayName =
            assetIn.unitName ??
            assetIn.name ??
            "\(assetIn.id)"

        let assetOutDisplayName =
            assetOut.unitName ??
            assetOut.name ??
            "\(assetOut.id)"

        let swapAssets = "\(assetInDisplayName) / \(assetOutDisplayName)"
        title = "swap-success-title"
            .localized(params: swapAssets)
            .bodyLargeMedium(alignment: .center)
    }

    mutating func bindDetail(
        _ quote: SwapQuote
    ) {
        guard let amountIn = quote.amountIn,
              let amountOut = quote.amountOutWithSlippage,
              let assetIn = quote.assetIn,
              let assetOut = quote.assetOut else {
            return
        }

        let assetInDisplayName =
            assetIn.unitName ??
            assetIn.name ??
            "\(assetIn.id)"

        let assetOutDisplayName =
            assetOut.unitName ??
            assetOut.name ??
            "\(assetOut.id)"

        /// <todo> Update display formatting when the flow is completed.
        let amountInDisplay = "\(amountIn) \(assetInDisplayName)"
        let amountOutDisplay = "\(amountOut) \(assetOutDisplayName)"

        detail = "swap-success-detail"
            .localized(params: amountInDisplay, amountOutDisplay)
            .bodyRegular(alignment: .center)
    }
}
