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
//   RewardInfoViewModel.swift

import UIKit
import MacaroonUIKit

struct RewardInfoViewModel:
    ViewModel,
    Hashable {
    private let account: Account

    private(set) var title: TextProvider?
    private(set) var value: TextProvider?

    init(
        account: Account,
        rewards: Decimal?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        self.account = account

        bindTitle()
        bindValue(
            account: account,
            rewards: rewards,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }
}

extension RewardInfoViewModel {
    mutating func bindTitle() {
        title = "rewards-title"
            .localized
            .footnoteRegular(hasMultilines: false)
    }

    mutating func bindValue(
        account: Account,
        rewards: Decimal?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        do {
            guard let algoRawCurrency = try currency.algoRawCurrency else {
                value = nil
                return
            }

            let totalRewards = calculateTotalRewards(
                account: account,
                rewards: rewards
            )

            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = algoRawCurrency

            let text = currencyFormatter.format(totalRewards)
            value = text?.footnoteMonoRegular(hasMultilines: false)
        } catch {
            value = nil
        }
    }
}

extension RewardInfoViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(value?.string)
    }

    static func == (
        lhs: RewardInfoViewModel,
        rhs: RewardInfoViewModel
    ) -> Bool {
        return lhs.value?.string == rhs.value?.string
    }
}

extension RewardInfoViewModel {
    private func calculateTotalRewards(
        account: Account,
        rewards: Decimal?
    ) -> Decimal {
        let someRewards = rewards ?? 0
        return account.pendingRewards.toAlgos + someRewards
    }
}
