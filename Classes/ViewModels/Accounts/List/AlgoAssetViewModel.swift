//
//  AlgoAssetViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

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
