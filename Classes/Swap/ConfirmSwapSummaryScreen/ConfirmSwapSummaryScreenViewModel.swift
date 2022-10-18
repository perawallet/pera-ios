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

//   ConfirmSwapSummaryScreenViewModel.swift

import MacaroonUIKit

struct ConfirmSwapSummaryScreenViewModel: ViewModel {
    private(set) var accountInfo: SecondaryListItemViewModel?
    private(set) var priceInfo: SwapInfoItemViewModel?
    private(set) var slippageInfo: SwapInfoItemViewModel?
    private(set) var priceImpactInfo: SwapInfoItemViewModel?
    private(set) var minimumReceivedInfo: SwapInfoItemViewModel?
    private(set) var totalSwapFeeInfo: SwapInfoItemViewModel?
    private(set) var exchangeFeeInfo: SwapInfoItemViewModel?
    private(set) var peraFeeInfo: SwapInfoItemViewModel?

    init(
        account: Account,
        quote: SwapQuote
    ) {
        bindAccountInfo(account)
        bindPriceInfo(quote)
        bindSlippageInfo(quote)
        bindPriceImpactInfo(quote)
        bindMinimumReceivedInfo(quote)
        bindExchangeFeeInfo(quote)
        bindPeraFeeInfo(quote)
        bindTotalSwapFeeInfo(quote)
    }
}

extension ConfirmSwapSummaryScreenViewModel {
    mutating func bindAccountInfo(
        _ account: Account
    ) {
        accountInfo = AccountSecondaryListItemViewModel(account: account)
    }

    mutating func bindPriceInfo(
        _ quote: SwapQuote
    ) {
        priceInfo = SwapConfirmSummaryPriceInfoViewModel(quote)
    }

    mutating func bindSlippageInfo(
        _ quote: SwapQuote
    ) {
        slippageInfo = SwapConfirmSummarySlippageToleranceInfoViewModel(quote)
    }

    mutating func bindPriceImpactInfo(
        _ quote: SwapQuote
    ) {
        priceImpactInfo = SwapConfirmSummaryPriceImpactInfoViewModel(quote)
    }

    mutating func bindMinimumReceivedInfo(
        _ quote: SwapQuote
    ) {
        minimumReceivedInfo = SwapConfirmSummaryMinimumReceivedInfoViewModel(quote)
    }

    mutating func bindExchangeFeeInfo(
        _ quote: SwapQuote
    ) {
        exchangeFeeInfo = SwapConfirmSummaryExchangeFeeInfoViewModel(quote)
    }

    mutating func bindPeraFeeInfo(
        _ quote: SwapQuote
    ) {
        peraFeeInfo = SwapConfirmSummaryPeraFeeInfoViewModel(quote)
    }

    mutating func bindTotalSwapFeeInfo(
        _ quote: SwapQuote
    ) {
        totalSwapFeeInfo = SwapConfirmSummaryTotalSwapFeeInfoViewModel(quote)
    }
}
