//
//  RewardDetailViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

class RewardDetailViewModel {
    
    func configure(_ view: RewardDetailView, for account: Account) {
        var totalRewards: UInt64 = 0
        let pendingRewards = account.pendingRewards ?? 0
        totalRewards += (account.rewards ?? 0) + pendingRewards
        
        view.totalRewardAmountContainerView.amountLabel.text = totalRewards.toAlgos.toDecimalStringForLabel
        view.pendingRewardAmountContainerView.amountLabel.text = pendingRewards.toAlgos.toDecimalStringForLabel
    }
}
