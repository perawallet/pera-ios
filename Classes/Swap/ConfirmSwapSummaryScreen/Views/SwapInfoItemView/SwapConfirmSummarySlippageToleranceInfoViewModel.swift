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

//   SwapConfirmSummarySlippageToleranceInfoViewModel.swift

import MacaroonUIKit

struct SwapConfirmSummarySlippageToleranceInfoViewModel: SwapInfoItemViewModel {
    private(set) var title: TextProvider?
    private(set) var icon: Image?
    private(set) var detail: TextProvider?
    private(set) var action: Image?

    init(
        _ quote: SwapQuote
    ) {
        bindTitle()
        bindIcon()
        bindDetail(quote)
        bindAction()
    }
}

extension SwapConfirmSummarySlippageToleranceInfoViewModel {
    mutating func bindTitle() {
        title = "swap-slippage-tolerance-info-title"
            .localized
            .bodyRegular()
    }

    mutating func bindIcon() {
        icon = nil
    }

    mutating func bindDetail(
        _ quote: SwapQuote
    ) {
        guard let slippage = quote.slippage else { return }

        detail = slippage
            .doubleValue
            .toPercentage?
            .bodyRegular()
    }

    mutating func bindAction() {
        action = nil
    }
}
