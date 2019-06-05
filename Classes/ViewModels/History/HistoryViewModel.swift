//
//  HistoryViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class HistoryViewModel {
    
    func configure(_ view: HistoryView, with account: Account) {
        view.accountSelectionView.detailLabel.text = account.name
        
        if account.amount == 0 {
            view.accountSelectionView.algosAmountView.algoIconImageView.image = img("icon-algo-small-black")
            view.accountSelectionView.algosAmountView.amountLabel.textColor = SharedColors.black
        } else {
            view.accountSelectionView.algosAmountView.algoIconImageView.image = img("icon-algo-small-green")
            view.accountSelectionView.algosAmountView.amountLabel.textColor = SharedColors.turquois
        }
        
        view.accountSelectionView.set(amount: account.amount.toAlgos)
    }
}
