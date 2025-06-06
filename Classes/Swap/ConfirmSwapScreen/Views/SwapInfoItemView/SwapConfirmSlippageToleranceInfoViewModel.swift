// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SwapConfirmSlippageToleranceInfoViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SwapConfirmSlippageToleranceInfoViewModel: SwapInfoItemViewModel {
    private(set) var title: TextProvider?
    private(set) var icon: Image?
    private(set) var iconTintColor: Color?
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

extension SwapConfirmSlippageToleranceInfoViewModel {
    mutating func bindTitle() {
        title = String(localized: "swap-slippage-title")
            .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindIcon() {
        icon = "icon-info-20"
    }

    mutating func bindDetail(
        _ quote: SwapQuote
    ) {
        guard let slippage = quote.slippage else { return }

        detail = slippage
            .doubleValue
            .toPercentageWith(fractions: 2)?
            .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindAction() {
        action = "icon-list-arrow"
    }
}
