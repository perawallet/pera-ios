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

//   TransactionFeeSecondaryListItemViewModel.swift

import Foundation
import MacaroonUIKit

struct TransactionFeeSecondaryListItemViewModel: SecondaryListItemViewModel {
    var title: TextProvider?
    var accessory: ButtonStyle?

    init(
        fee: UInt64
    ) {
        bindTitle()
        bindAccessory(fee)
    }
}

extension TransactionFeeSecondaryListItemViewModel {
    private mutating func bindTitle() {
        title = getTitle(title: "collectible-approve-transaction-fee".localized)
    }

    private mutating func bindAccessory(
        _ fee: UInt64
    ) {
        let formatter = CurrencyFormatter()
        formatter.formattingContext = .standalone()
        formatter.currency = AlgoLocalCurrency()
        let unformattedFee = fee.toAlgos
        let formattedFee = formatter.format(unformattedFee)

        accessory = getNonInteractableAccessory(
            title: formattedFee ?? "\(unformattedFee)"
        )
    }
}
