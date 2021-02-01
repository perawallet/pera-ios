//
//  AlgoAssetViewModel.swift

import Foundation

class AlgoAssetViewModel {
    private(set) var amount: String?

    init(account: Account) {
        setAmount(from: account)
    }

    private func setAmount(from account: Account) {
        amount = account.amount.toAlgos.toAlgosStringForLabel
    }
}
