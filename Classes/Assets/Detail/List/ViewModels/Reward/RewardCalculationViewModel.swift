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
//   RewardCalculationViewModel.swift

import UIKit
import MacaroonUIKit

final class RewardCalculationViewModel: ViewModel, Hashable {
    private let account: Account
    private(set) var rewardAmount: String?

    init(account: Account, calculatedRewards: Decimal) {
        self.account = account
        bindRewardAmount(from: account, and: calculatedRewards)
    }

    static func == (lhs: RewardCalculationViewModel, rhs: RewardCalculationViewModel) -> Bool {
        return lhs.account == rhs.account && lhs.rewardAmount == rhs.rewardAmount
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(account.address.hashValue)
    }
}

extension RewardCalculationViewModel {
    private func bindRewardAmount(from account: Account, and calculatedRewards: Decimal) {
        rewardAmount = (account.pendingRewards.toAlgos + calculatedRewards).toExactFractionLabel(fraction: 6)
    }
}
