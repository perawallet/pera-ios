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

//   SwapConfirmSummaryTotalSwapFeeInfoViewModel.swift

import MacaroonUIKit

struct SwapConfirmSummaryTotalSwapFeeInfoViewModel: SwapInfoItemViewModel {
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

extension SwapConfirmSummaryTotalSwapFeeInfoViewModel {
    mutating func bindTitle() {
        let aTitle = "swap-confirm-total-fee-title".localized + "*"

        var attributes = Typography.bodyMediumAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Text.main))
        title = aTitle.attributed(attributes)
    }

    mutating func bindIcon() {
        icon = nil
    }

    mutating func bindDetail(
        _ quote: SwapQuote
    ) {
        guard let peraFee = quote.peraFee?.toAlgos,
              let exchangeFee = quote.peraFee?.toAlgos else {
            return
        }

        detail = "\(peraFee + exchangeFee)".bodyMedium() /// <todo> Will handle formatting when the flow is completed.
    }

    mutating func bindAction() {
        action = nil
    }
}
