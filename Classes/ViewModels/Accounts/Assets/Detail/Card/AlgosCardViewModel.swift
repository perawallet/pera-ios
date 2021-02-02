//
//  AlgosCardViewModel.swift

import UIKit

class AlgosCardViewModel {
    
    private(set) var amount: String?
    private(set) var reward: String?
    private(set) var currency: String?
    
    init(account: Account, currency: Currency?) {
        setAmount(from: account)
        setReward(from: account)
        setCurrency(from: account, and: currency)
    }
    
    private func setAmount(from account: Account) {
        amount = account.amount.toAlgos.toAlgosStringForLabel
    }
    
    private func setReward(from account: Account) {
        let totalRewards: UInt64 = (account.pendingRewards ?? 0)
        reward = "total-rewards-title".localized(params: totalRewards.toAlgos.toAlgosStringForLabel ?? "0.00") 
    }
    
    private func setCurrency(from account: Account, and currency: Currency?) {
        guard let currentCurrency = currency,
              let price = currentCurrency.price,
              let priceDoubleValue = Double(price) else {
            return
        }
        
        let currencyAmountForAccount = account.amount.toAlgos * priceDoubleValue
        
        if let currencyValue = currencyAmountForAccount.toCurrencyStringForLabel {
            self.currency = currencyValue + " " + currentCurrency.id
        }
    }
}
