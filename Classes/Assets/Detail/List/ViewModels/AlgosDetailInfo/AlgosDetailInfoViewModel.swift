// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   AlgosDetailInfoViewModel.swift

import Foundation
import MacaroonUIKit

struct AlgosDetailInfoViewModel:
    ViewModel,
    Hashable {
    private(set) var totalAmount: String?
    private(set) var secondaryValue: String?
    private(set) var rewardsInfoViewModel: RewardDetailViewModel?

    init(
        _ account: Account,
        _ currency: Currency?
    ) {
        bindTotalAmount(from: account)
        bindSecondaryValue(from: account, with: currency)
        bindRewardsInfoViewModel(from: account)
    }
}

extension AlgosDetailInfoViewModel {
    private mutating func bindTotalAmount(from account: Account) {
        totalAmount = account.amount.toAlgos.toAlgosStringForLabel
    }

    private mutating func bindSecondaryValue(from account: Account, with currency: Currency?) {
        guard let currency = currency,
              let currencyPriceValue = currency.priceValue else {
            return
        }

        let totalAmount = account.amount.toAlgos * currencyPriceValue
        secondaryValue = totalAmount.toCurrencyStringForLabel(with: currency.symbol)
    }

    private mutating func bindRewardsInfoViewModel(from account: Account) {
        rewardsInfoViewModel = RewardDetailViewModel(account)
    }
}
