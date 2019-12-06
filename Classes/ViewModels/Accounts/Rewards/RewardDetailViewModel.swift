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
        let totalRewards: UInt64 = (account.rewards ?? 0)
        view.totalRewardAmountContainerView.amountLabel.text = totalRewards.toAlgos.toDecimalStringForLabel
    }
}
