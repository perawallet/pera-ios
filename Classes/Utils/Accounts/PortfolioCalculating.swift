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
//   PortfolioCalculating.swift

import Foundation

protocol PortfolioCalculating {
    func calculatePortfolio(
        for accounts: [Account],
        with currency: Currency?
    ) -> Decimal?
    func calculateAlgoHoldings(
        for accounts: [Account],
        with currency: Currency?
    ) -> Decimal?
    func calculateAssetHoldings(
        for accounts: [Account],
        with currency: Currency?
    ) -> Decimal?
}

extension PortfolioCalculating {
    func calculatePortfolio(
        for accounts: [Account],
        with currency: Currency?
    ) -> Decimal? {
        guard let totalAlgoHoldings = calculateAlgoHoldings(for: accounts, with: currency),
              let totalAssetHoldings = calculateAssetHoldings(for: accounts, with: currency) else {
                  return nil
              }

        return totalAlgoHoldings + totalAssetHoldings
    }

    func calculateAlgoHoldings(
        for accounts: [Account],
        with currency: Currency?
    ) -> Decimal? {
        guard let price = currency?.price,
              let currencyPrice = Decimal(string: price) else {
            return nil
        }

        let totalAlgoCurrencyValue = accounts.map( {$0.amount} ).reduce(0, +).toAlgos * currencyPrice
        return totalAlgoCurrencyValue
    }

    func calculateAssetHoldings(
        for accounts: [Account],
        with currency: Currency?
    ) -> Decimal? {
        guard let price = currency?.price,
              let currencyPrice = Decimal(string: price) else {
            return nil
        }

        var totalAssetCurrencyValue: Decimal = 0
        for account in accounts where !account.assetInformations.isEmpty {
            for assetInformation in account.assetInformations {
                guard let amount = account.amount(for: assetInformation) else {
                    continue
                }

                totalAssetCurrencyValue += currencyPrice * amount
            }
        }

        return totalAssetCurrencyValue
    }
}
