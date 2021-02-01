//
//  RewardViewModel.swift

import Foundation

class RewardViewModel {
    
    private(set) var amountMode: TransactionAmountView.Mode?
    private(set) var date: String?
    
    init(reward: Reward) {
        setAmountMode(from: reward)
        setDate(from: reward)
    }
    
    private func setAmountMode(from reward: Reward) {
        amountMode = .positive(amount: reward.amount.toAlgos)
    }
    
    private func setDate(from reward: Reward) {
        date = reward.date?.toFormat("MMMM dd, yyyy")
    }
}
