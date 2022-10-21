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

//   SwapConfirmTotalFeeInfoViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SwapConfirmTotalFeeInfoViewModel: SwapInfoItemViewModel {
    private(set) var title: TextProvider?
    private(set) var icon: Image?
    private(set) var detail: TextProvider?
    private(set) var action: Image?

    init(
        quote: SwapQuote,
        currencyFormatter: CurrencyFormatter
    ) {
        bindTitle()
        bindIcon()
        bindDetail(
            quote: quote,
            currencyFormatter: currencyFormatter
        )
        action = nil
    }
}

extension SwapConfirmTotalFeeInfoViewModel {
    mutating func bindTitle() {
        title = "swap-confirm-total-fee-title"
            .localized
            .footnoteRegular()
    }

    mutating func bindIcon() {
        icon = nil
    }

    mutating func bindDetail(
        quote: SwapQuote,
        currencyFormatter: CurrencyFormatter
    ) {
        let totalFee = quote.peraFee.unwrap(or: 0) + quote.exchangeFee.unwrap(or: 0)
        currencyFormatter.formattingContext = .standalone()
        currencyFormatter.currency = AlgoLocalCurrency()
        detail = currencyFormatter
            .format(totalFee.toAlgos)?
            .footnoteRegular()
    }
}
