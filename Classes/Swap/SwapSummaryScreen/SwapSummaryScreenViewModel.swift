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

//   SwapSummaryScreenViewModel.swift

import MacaroonUIKit
import UIKit

struct SwapSummaryScreenViewModel: ViewModel {
    private(set) var receivedInfo: SwapSummaryItemViewModel?
    private(set) var paidInfo: SwapSummaryItemViewModel?
    private(set) var statusInfo: TransactionStatusViewModel?
    private(set) var accountInfo: SwapSummaryAccountViewModel?
    private(set) var algorandFeeInfo: SwapSummaryItemViewModel?
    private(set) var optInFeeInfo: SwapSummaryItemViewModel?
    private(set) var exchangeFeeInfo: SwapSummaryItemViewModel?
    private(set) var peraFeeInfo: SwapSummaryItemViewModel?
    private(set) var priceImpactInfo: SwapSummaryItemViewModel?

    init(
        account: Account,
        quote: SwapQuote
    ) {
        bindReceivedInfo(quote)
        bindPaidInfo(quote)
        bindStatusInfo()
        bindAccountInfo(account)
        bindAlgorandFeeInfo(quote)
        bindOptInFeeInfo(quote)
        bindExchangeFeeInfo(quote)
        bindPeraFeeInfo(quote)
        bindPriceImpactInfo(quote)
    }
}

extension SwapSummaryScreenViewModel {
    mutating func bindReceivedInfo(
        _ quote: SwapQuote
    ) {
        receivedInfo = SwapSummaryReceivedItemViewModel(quote)
    }

    mutating func bindPaidInfo(
        _ quote: SwapQuote
    ) {
        paidInfo = SwapSummaryPaidItemViewModel(quote)
    }

    mutating func bindStatusInfo() {
        statusInfo = TransactionStatusViewModel(.completed)
    }

    mutating func bindAccountInfo(
        _ account: Account
    ) {
        accountInfo = SwapSummaryAccountViewModel(account)
    }

    mutating func bindAlgorandFeeInfo(
        _ quote: SwapQuote
    ) {
        exchangeFeeInfo = SwapSummaryAlgorandFeeItemViewModel(quote)
    }

    mutating func bindOptInFeeInfo(
        _ quote: SwapQuote
    ) {
        /// <todo> Will be set nil if needed when the flow is completed.
        exchangeFeeInfo = SwapSummaryOptInFeeItemViewModel(quote)
    }

    mutating func bindExchangeFeeInfo(
        _ quote: SwapQuote
    ) {
        exchangeFeeInfo = SwapSummaryExchangeFeeItemViewModel(quote)
    }

    mutating func bindPeraFeeInfo(
        _ quote: SwapQuote
    ) {
        peraFeeInfo = SwapSummaryPeraFeeItemViewModel(quote)
    }

    mutating func bindPriceImpactInfo(
        _ quote: SwapQuote
    ) {
        priceImpactInfo = SwapSummaryPriceImpactItemViewModel(quote)
    }
}
