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

import MacaroonUIKit

final class AccountPortfolioViewModel: ViewModel {
    private(set) var portfolioValueViewModel: PortfolioValueViewModel?
    private(set) var algoHoldingsValue: EditText?
    private(set) var assetHoldingsValue: EditText?

    init(
        _ accounts: [Account]
    ) {
        bindPortfolioValueViewModel(accounts)
        bindAlgoHoldingsValue(accounts)
        bindAssetHoldingsValue(accounts)
    }
}

extension AccountPortfolioViewModel {
    private func bindPortfolioValueViewModel(
        _ accounts: [Account]
    ) {
        let totalAlgo = accounts.map( {$0.amount} ).reduce(0, +).toAlgos
        portfolioValueViewModel = PortfolioValueViewModel(.all(value: .value(totalAlgo)))
    }

    private func bindAlgoHoldingsValue(
        _ accounts: [Account]
    ) {
        let totalAlgo = accounts.map( {$0.amount} ).reduce(0, +).toAlgos
        algoHoldingsValue = .string("\(totalAlgo)")
    }

    private func bindAssetHoldingsValue(
        _ accounts: [Account]
    ) {
        assetHoldingsValue = .string("1234")
    }
}
