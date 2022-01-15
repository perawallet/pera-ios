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
//   AccountPortfolioViewModel.swift

import Foundation
import MacaroonUIKit

struct AccountPortfolioViewModel:
    ViewModel,
    Hashable {
    private(set) var portfolioValueViewModel: PortfolioValueViewModel?
    private(set) var algoHoldingsValue: EditText?
    private(set) var assetHoldingsValue: EditText?

    init(
        _ accounts: [Account],
        currency: Currency?
    ) {
        bindPortfolioValueViewModel(accounts, currency)
        bindAlgoHoldingsValue(accounts, currency)
        bindAssetHoldingsValue(accounts, currency)
    }
    
    init(
        _ accountCollection: AccountCollection
    ) {
        self.init(accountCollection.map(\.value), currency: nil)
    }
}

extension AccountPortfolioViewModel {
    private mutating func bindPortfolioValueViewModel(
        _ accounts: [Account],
        _ currency: Currency?
    ) {
//        if let totalPortfolioValue = calculatePortfolio(for: accounts, with: currency) {
//            portfolioValueViewModel = PortfolioValueViewModel(.all(value: .value(totalPortfolioValue)), currency)
//            return
//        }
//
//        portfolioValueViewModel = PortfolioValueViewModel(.all(value: .unknown), currency)
    }

    private mutating func bindAlgoHoldingsValue(
        _ accounts: [Account],
        _ currency: Currency?
    ) {
//        if let totalAlgoHoldings = calculateAlgoHoldings(for: accounts, with: currency),
//           let currency = currency {
//            algoHoldingsValue = .string(totalAlgoHoldings.toCurrencyStringForLabel(with: currency.id))
//            return
//        }
//
//        algoHoldingsValue = .string("N/A")
    }

    private mutating func bindAssetHoldingsValue(
        _ accounts: [Account],
        _ currency: Currency?
    ) {
//        if let totalAssetHoldings = calculateAssetHoldings(for: accounts, with: currency),
//           let currency = currency {
//            assetHoldingsValue = .string(totalAssetHoldings.toCurrencyStringForLabel(with: currency.id))
//            return
//        }
//
//        assetHoldingsValue = .string("N/A")
    }
}
