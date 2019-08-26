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
        view.accountSelectionView.set(amount: account.amount.toAlgos)
    }
}
