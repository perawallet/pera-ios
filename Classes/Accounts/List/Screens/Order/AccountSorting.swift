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

//   AccountSorting.swift

import Foundation

protocol AccountSorting {
    var id: String { get }
    var title: String { get }

    func sort(
        _ accounts: [AccountHandle]
    ) -> [AccountHandle]
}

struct AccountSortingWithAlphabeticallyDescending: AccountSorting {
    var id: String = "alphabeticallyDescending"
    var title: String = "title-alphabetically-z-to-a".localized

    func sort(
        _ accounts: [AccountHandle]
    ) -> [AccountHandle] {
        return accounts.sorted { first, second in
            guard let firstValue = first.value.name,
                  let secondValue = second.value.name else {
                return false
            }

            return firstValue.localizedCaseInsensitiveCompare(secondValue) == .orderedDescending
        }
    }
}

struct AccountSortingWithAlphabeticallyAscending: AccountSorting {
    var id: String = "alphabeticallyAscending"
    var title: String = "title-alphabetically-a-to-z".localized

    func sort(
        _ accounts: [AccountHandle]
    ) -> [AccountHandle] {
        return accounts.sorted { first, second in
            guard let firstValue = first.value.name,
                  let secondValue = second.value.name else {
                return false
            }

            return firstValue.localizedCaseInsensitiveCompare(secondValue) == .orderedAscending
        }
    }
}

struct AccountSortingWithValueDescending: AccountSorting {
    var id: String = "valueDescending"
    var title: String = "title-highest-value-to-lowest".localized

    private let currency: CurrencyHandle
    private let calculator: PortfolioCalculator

    init(
        currency: CurrencyHandle,
        calculator: PortfolioCalculator
    ) {
        self.currency = currency
        self.calculator = calculator
    }

    func sort(
        _ accounts: [AccountHandle]
    ) -> [AccountHandle] {
        var totalValueCache: [String: Decimal] = [:]

        return accounts.sorted { first, second in
            let firstTotalValue: Decimal = getTotalValue(
                for: first,
                cache: &totalValueCache
            )

            let secondTotalValue: Decimal = getTotalValue(
                for: second,
                cache: &totalValueCache
            )

            return firstTotalValue > secondTotalValue
        }
    }

    private func getTotalValue(
        for accountHandle: AccountHandle,
        cache: inout [String: Decimal]
    ) -> Decimal {
        let account = accountHandle.value

        if let totalValueFromCache = cache[account.address] {
            return totalValueFromCache
        }

        let calculatedTotalValue = calculator.calculateTotalValue(
            [accountHandle],
            as: currency
        ).amount

        cache[account.address] = calculatedTotalValue

        return calculatedTotalValue
    }
}

struct AccountSortingWithValueAscending: AccountSorting {
    var id: String = "valueAscending"
    var title: String = "title-lowest-value-to-highest".localized

    private let currency: CurrencyHandle
    private let calculator: PortfolioCalculator

    init(
        currency: CurrencyHandle,
        calculator: PortfolioCalculator
    ) {
        self.currency = currency
        self.calculator = calculator
    }

    func sort(
        _ accounts: [AccountHandle]
    ) -> [AccountHandle] {
        var totalValueCache: [String: Decimal] = [:]

        return accounts.sorted { first, second in
            let firstTotalValue: Decimal = getTotalValue(
                for: first,
                cache: &totalValueCache
            )

            let secondTotalValue: Decimal = getTotalValue(
                for: second,
                cache: &totalValueCache
            )

            return firstTotalValue < secondTotalValue
        }
    }

    private func getTotalValue(
        for accountHandle: AccountHandle,
        cache: inout [String: Decimal]
    ) -> Decimal {
        let account = accountHandle.value

        if let totalValueFromCache = cache[account.address] {
            return totalValueFromCache
        }

        let calculatedTotalValue = calculator.calculateTotalValue(
            [accountHandle],
            as: currency
        ).amount

        cache[account.address] = calculatedTotalValue

        return calculatedTotalValue
    }
}

struct AccountSortingWithManually: AccountSorting {
    var id: String = "manually"
    var title: String = "title-manually".localized

    func sort(
        _ accounts: [AccountHandle]
    ) -> [AccountHandle] {
        return accounts
    }
}
