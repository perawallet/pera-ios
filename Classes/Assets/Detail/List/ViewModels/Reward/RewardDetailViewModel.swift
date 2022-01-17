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
//  RewardDetailViewModel.swift

import Foundation
import MacaroonUIKit

struct RewardDetailViewModel:
    PairedViewModel,
    Hashable {
    private(set) var rate: String?
    private(set) var amount: String?

    init(_ account: Account) {
        bindRate(from: account)
        bindAmount(from: account)
    }

    /**
     * <src>: https://www.purestake.com/blog/algorand-rewards-distribution-explained/
     * The current daily rewards percentage return based on the assumption of 1 microAlgo every 3 minutes is:
     * (10^-6 * 60 * 24 * 365) / 3 * 100% = Yearly Rewards Rate = 17.52%
     */
    private let yearlyRewardsRate = 17.52
}

extension RewardDetailViewModel {
    private mutating func bindRate(from account: Account) {
        rate = (yearlyRewardsRate / 100.0).toPercentage
    }

    private mutating func bindAmount(from account: Account) {
        amount = account.pendingRewards.toAlgos.toExactFractionLabel(fraction: 6)?.appending(" ALGO")
    }
}
