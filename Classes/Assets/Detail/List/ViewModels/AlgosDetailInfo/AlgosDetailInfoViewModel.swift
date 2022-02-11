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

//
//   AlgosDetailInfoViewModel.swift

import Foundation
import MacaroonUIKit

struct AlgosDetailInfoViewModel:
    ViewModel,
    Hashable {
    private(set) var totalAmount: String?
    private(set) var secondaryValue: String?
    private(set) var rewardsInfoViewModel: RewardCalculationViewModel?

    init(
        _ account: Account,
        _ currency: Currency?,
        _ calculatedRewards: Decimal?
    ) {
        bindTotalAmount(from: account, calculatedRewards: calculatedRewards ?? 0)
        bindSecondaryValue(from: account, with: currency, calculatedRewards: calculatedRewards ?? 0)
        bindRewardsInfoViewModel(from: account, rewards: calculatedRewards ?? 0)
    }
}

extension AlgosDetailInfoViewModel {
    private mutating func bindTotalAmount(from account: Account, calculatedRewards: Decimal) {
        totalAmount = getTotalAmount(from: account, and: calculatedRewards).toAlgosStringForLabel
    }

    private mutating func bindSecondaryValue(from account: Account, with currency: Currency?, calculatedRewards: Decimal) {
        guard let currency = currency,
              let currencyPriceValue = currency.priceValue else {
            return
        }

        let totalAmount = getTotalAmount(from: account, and: calculatedRewards) * currencyPriceValue
        secondaryValue = totalAmount.toCurrencyStringForLabel(with: currency.symbol)
    }

    private mutating func bindRewardsInfoViewModel(from account: Account, rewards: Decimal) {
        rewardsInfoViewModel = RewardCalculationViewModel(account: account, calculatedRewards: rewards)
    }

    private func getTotalAmount(from account: Account, and calculatedRewards: Decimal) -> Decimal {
        return account.amountWithoutRewards.toAlgos + getPendingRewards(from: account, and: calculatedRewards)
    }

    private func getPendingRewards(from account: Account, and calculatedRewards: Decimal) -> Decimal {
        return account.pendingRewards.toAlgos + calculatedRewards
    }
}
