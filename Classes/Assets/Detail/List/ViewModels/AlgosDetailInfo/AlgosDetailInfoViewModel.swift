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
    private(set) var yourBalanceTitle: EditText?
    private(set) var totalAmount: EditText?
    private(set) var secondaryValue: EditText?
    private(set) var rewardsInfoViewModel: RewardInfoViewModel?
    private(set) var hasBuyAlgoButton: Bool = false

    init(
        _ account: Account,
        _ currency: Currency?,
        _ calculatedRewards: Decimal?
    ) {
        bindYourBalanceTitle()
        bindTotalAmount(from: account, calculatedRewards: calculatedRewards ?? 0)
        bindSecondaryValue(from: account, with: currency, calculatedRewards: calculatedRewards ?? 0)
        bindRewardsInfoViewModel(from: account, rewards: calculatedRewards ?? 0)
        hasBuyAlgoButton = !account.isWatchAccount()
    }
}

extension AlgosDetailInfoViewModel {
    private mutating func bindYourBalanceTitle() {
        yourBalanceTitle = .attributedString(
            "accounts-transaction-your-balance"
                .localized
                .bodyRegular()
        )
    }
    
    private mutating func bindTotalAmount(from account: Account, calculatedRewards: Decimal) {
        guard let totalAmount =
                getTotalAmount(from: account, and: calculatedRewards)
                .toAlgosStringForLabel else {
                    return
                }
        

        self.totalAmount = .attributedString(
            totalAmount
                .largeTitleMonoRegular()
        )
    }

    private mutating func bindSecondaryValue(from account: Account, with currency: Currency?, calculatedRewards: Decimal) {
        guard let currency = currency,
              let currencyPriceValue = currency.priceValue,
              !(currency is AlgoCurrency) else {
            return
        }

        let totalAmount = getTotalAmount(from: account, and: calculatedRewards) * currencyPriceValue
        let secondaryValue = totalAmount.toCurrencyStringForLabel(with: currency.symbol)

        guard let secondaryValue = secondaryValue else {
            return
        }

        self.secondaryValue = .attributedString(
            secondaryValue
                .bodyMonoRegular()
        )
    }

    private mutating func bindRewardsInfoViewModel(from account: Account, rewards: Decimal) {
        rewardsInfoViewModel = RewardInfoViewModel(account: account, calculatedRewards: rewards)
    }

    private func getTotalAmount(from account: Account, and calculatedRewards: Decimal) -> Decimal {
        return account.amountWithoutRewards.toAlgos + getPendingRewards(from: account, and: calculatedRewards)
    }

    private func getPendingRewards(from account: Account, and calculatedRewards: Decimal) -> Decimal {
        return account.pendingRewards.toAlgos + calculatedRewards
    }
}
