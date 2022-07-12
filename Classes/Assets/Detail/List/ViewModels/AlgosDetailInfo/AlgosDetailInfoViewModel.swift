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
    private(set) var title: TextProvider?
    private(set) var primaryValue: TextProvider?
    private(set) var secondaryValue: TextProvider?
    private(set) var rewardsInfo: RewardInfoViewModel?
    private(set) var isBuyAlgoAvailable: Bool = false

    init(
        account: Account,
        rewards: Decimal?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        bindTitle()
        bindPrimaryValue(
            account: account,
            rewards: rewards,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        bindSecondaryValue(
            account: account,
            rewards: rewards,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        bindRewardsInfo(
            account: account,
            rewards: rewards,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        bindIsBuyAlgoAvailable(account)
    }
}

extension AlgosDetailInfoViewModel {
    mutating func bindTitle() {
        title = "accounts-transaction-your-balance"
            .localized
            .bodyRegular(hasMultilines: false)
    }
    
    mutating func bindPrimaryValue(
        account: Account,
        rewards: Decimal?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        do {
            guard let algoRawCurrency = try currency.algoRawCurrency else {
                primaryValue = nil
                return
            }

            let amount = calculateTotalAmount(
                account: account,
                rewards: rewards
            )

            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = algoRawCurrency

            let text = currencyFormatter.format(amount)
            primaryValue = text?.largeTitleMonoRegular(hasMultilines: false)
        } catch {
            primaryValue = nil
        }
    }

    mutating func bindSecondaryValue(
        account: Account,
        rewards: Decimal?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        do {
            guard let fiatRawCurrency = try currency.fiatRawCurrency else {
                secondaryValue = nil
                return
            }

            let algoAmount = calculateTotalAmount(
                account: account,
                rewards: rewards
            )
            let exchanger = CurrencyExchanger(currency: fiatRawCurrency)
            let amount = try exchanger.exchange(algo: algoAmount)

            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = fiatRawCurrency

            let text = currencyFormatter.format(amount)
            secondaryValue = text?.bodyMonoRegular(hasMultilines: false)
        } catch {
            secondaryValue = nil
        }
    }

    mutating func bindRewardsInfo(
        account: Account,
        rewards: Decimal?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        rewardsInfo = RewardInfoViewModel(
            account: account,
            rewards: rewards,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }

    mutating func bindIsBuyAlgoAvailable(
        _ account: Account
    ) {
        isBuyAlgoAvailable = !account.isWatchAccount()
    }
}

extension AlgosDetailInfoViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(primaryValue?.string)
        hasher.combine(secondaryValue?.string)
        hasher.combine(rewardsInfo)
        hasher.combine(isBuyAlgoAvailable)
    }

    static func == (
        lhs: AlgosDetailInfoViewModel,
        rhs: AlgosDetailInfoViewModel
    ) -> Bool {
        return
            lhs.primaryValue?.string == rhs.primaryValue?.string &&
            lhs.secondaryValue?.string == rhs.secondaryValue?.string &&
            lhs.rewardsInfo == rhs.rewardsInfo &&
            lhs.isBuyAlgoAvailable == rhs.isBuyAlgoAvailable
    }
}

extension AlgosDetailInfoViewModel {
    private func calculateTotalAmount(
        account: Account,
        rewards: Decimal?
    ) -> Decimal {
        let totalRewards = calculateTotalRewards(
            account: account,
            rewards: rewards
        )
        return account.amountWithoutRewards.toAlgos + totalRewards
    }

    private func calculateTotalRewards(
        account: Account,
        rewards: Decimal?
    ) -> Decimal {
        /// <todo>
        /// We should create a type to hold the algo values otherwise it may cause some issues while
        /// figuring out what refers to `Decimal` type.
        let someRewards = rewards ?? 0
        return account.pendingRewards.toAlgos + someRewards
    }
}
