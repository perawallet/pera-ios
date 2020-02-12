//
//  SendTransactionViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SendTransactionViewModel {
    func configure(_ view: SendTransactionView, with state: AssetReceiverState, and fee: Int64?) {
        view.transactionReceiverView.state = state
        view.transactionReceiverView.receiverContainerView.backgroundColor = rgb(0.91, 0.91, 0.92)
        view.transactionReceiverView.actionMode = .none
        updateFeeLayout(view, with: fee)
    }
    
    private func updateFeeLayout(_ view: SendTransactionView, with fee: Int64?) {
        if var receivedFee = fee {
            if receivedFee < Transaction.Constant.minimumFee {
                receivedFee = Transaction.Constant.minimumFee
            }
            view.feeInformationView.algosAmountView.mode = .normal(amount: receivedFee.toAlgos)
        }
    }
}
