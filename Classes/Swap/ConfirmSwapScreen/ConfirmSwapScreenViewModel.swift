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

//   ConfirmSwapScreenViewModel.swift

import Foundation
import MacaroonUIKit

struct ConfirmSwapScreenViewModel: ViewModel {
    private(set) var userAsset: SwapAssetAmountViewModel?
    private(set) var toSeparator: TitleSeparatorViewModel?
    private(set) var poolAsset: SwapAssetAmountViewModel?
    private(set) var priceInfo: SwapInfoItemViewModel?
    private(set) var slippageInfo: SwapInfoItemViewModel?
    private(set) var priceImpactInfo: SwapInfoItemViewModel?
    private(set) var minimumReceivedInfo: SwapInfoItemViewModel?
    private(set) var exchangeFeeInfo: SwapInfoItemViewModel?
    private(set) var peraFeeInfo: SwapInfoItemViewModel?

    init(
        quote: SwapQuote,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        bindUserAsset(
            quote: quote,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        bindToSeparator()
        bindPoolAsset(
            quote: quote,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        bindPriceInfo(quote)
        bindSlippageInfo(quote)
        bindPriceImpactInfo(quote)
        bindMinimumReceivedInfo(quote)
        bindExchangeFeeInfo(quote)
        bindPeraFeeInfo(quote)
    }
}

extension ConfirmSwapScreenViewModel {
    mutating func bindUserAsset(
        quote: SwapQuote,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let assetIn = quote.assetIn else { return }

        let asset: Asset
        if assetIn.isCollectible {
            asset = CollectibleAsset(decoration: assetIn)
        } else {
            asset = StandardAsset(decoration: assetIn)
        }

        userAsset = ConfirmSwapAmountInViewModel(
            asset: asset,
            quote: quote,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }

    mutating func bindToSeparator() {
        toSeparator = TitleSeparatorViewModel(
            "title-to"
                .localized
                .uppercased()
        )
    }

    mutating func bindPoolAsset(
        quote: SwapQuote,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let assetOut = quote.assetOut else { return }

        let asset: Asset
        if assetOut.isCollectible {
            asset = CollectibleAsset(decoration: assetOut)
        } else {
            asset = StandardAsset(decoration: assetOut)
        }

        poolAsset = ConfirmSwapAmountOutViewModel(
            asset: asset,
            quote: quote,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }

    mutating func bindPriceInfo(
        _ quote: SwapQuote
    ) {
        priceInfo = SwapConfirmPriceInfoViewModel(quote)
    }

    mutating func bindSlippageInfo(
        _ quote: SwapQuote
    ) {
        slippageInfo = SwapConfirmSlippageToleranceInfoViewModel(quote)
    }


    mutating func bindPriceImpactInfo(
        _ quote: SwapQuote
    ) {
        priceImpactInfo = SwapConfirmPriceImpactInfoViewModel(quote)
    }

    mutating func bindMinimumReceivedInfo(
        _ quote: SwapQuote
    ) {
        minimumReceivedInfo = SwapConfirmMinimumReceivedInfoViewModel(quote)
    }

    mutating func bindExchangeFeeInfo(
        _ quote: SwapQuote
    ) {
        exchangeFeeInfo = SwapConfirmExchangeFeeInfoViewModel(quote)
    }

    mutating func bindPeraFeeInfo(
        _ quote: SwapQuote
    ) {
        peraFeeInfo = SwapConfirmPeraFeeInfoViewModel(quote)
    }
}
