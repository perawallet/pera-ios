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

//   AccountAscendingTotalPortfolioValueAlgorithm.swift

import Foundation

struct AccountAscendingTotalPortfolioValueAlgorithm: AccountSortingAlgorithm {
    let id: String
    let name: String
    let isCustom: Bool

    init() {
        self.id = "cache.value.accountAscendingTotalPortfolioValueAlgorithm"
        self.name = "title-lowest-value-to-highest".localized
        self.isCustom = false
    }
}

extension AccountAscendingTotalPortfolioValueAlgorithm {
    func getFormula(
        account: AccountHandle,
        otherAccount: AccountHandle
    ) -> Bool {
        let accountTotalPortfolioValue = account.value.totalPortfolio.primaryAmount
        let otherAccountTotalPortfolioValue = otherAccount.value.totalPortfolio.primaryAmount
        return accountTotalPortfolioValue < otherAccountTotalPortfolioValue
    }
}
