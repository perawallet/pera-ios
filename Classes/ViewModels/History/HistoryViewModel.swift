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
        
        view.accountSelectionView.rightInputAccessoryButton.isHidden = true
        view.accountAmountView.isHidden = false
        
        if account.amount > 0 {
            view.accountAmountView.mode = .positive(account.amount.toAlgos)
        } else if account.amount == 0 {
            view.accountAmountView.mode = .normal(0.0)
        } else {
            view.accountAmountView.mode = .negative(-account.amount.toAlgos)
        }
        
        view.accountAmountView.signLabel.isHidden = true
    }
}
