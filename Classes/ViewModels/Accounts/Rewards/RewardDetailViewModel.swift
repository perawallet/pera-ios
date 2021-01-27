//
//  RewardDetailViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

class RewardDetailViewModel {
    private(set) var amount: String?

    init(account: Account) {
        setAmount(from: account)
    }

    private func setAmount(from account: Account) {
        let totalRewards: UInt64 = (account.pendingRewards ?? 0)
        amount = totalRewards.toAlgos.toAlgosStringForLabel
    }
}
