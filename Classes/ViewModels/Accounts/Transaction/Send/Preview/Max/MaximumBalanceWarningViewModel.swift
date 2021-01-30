//
//  MaximumBalanceWarningViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import UIKit

class MaximumBalanceWarningViewModel {
    private(set) var description: String?

    init(account: Account) {
        setDescription(from: account)
    }

    private func setDescription(from account: Account) {
        let params = UIApplication.shared.accountManager?.params
        let feeCalculator = TransactionFeeCalculator(transactionDraft: nil, transactionData: nil, params: params)
        let minimumAmountForAccount = feeCalculator.calculateMinimumAmount(
            for: account,
            with: .algosTransaction,
            calculatedFee: params?.getProjectedTransactionFee() ?? Transaction.Constant.minimumFee,
            isAfterTransaction: true
        )

        description = "maximum-balance-warning-description".localized(params: "\(minimumAmountForAccount)")
    }
}
