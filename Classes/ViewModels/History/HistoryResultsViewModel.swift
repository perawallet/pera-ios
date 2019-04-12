//
//  HistoryResultsViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class HistoryResultsViewModel {
    
    func configure(_ view: HistoryResultsView, with draft: HistoryDraft) {
        
        view.accountNameLabel.text = draft.account.name
        
        if draft.account.amount > 0 {
            view.accountAmountView.mode = .positive(draft.account.amount.toAlgos)
        } else if draft.account.amount == 0 {
            view.accountAmountView.mode = .normal(0.0)
        } else {
            view.accountAmountView.mode = .negative(-draft.account.amount.toAlgos)
        }
        
        view.startDateLabel.text = draft.startDate.toFormat("dd MMMM yyyy")
        view.endDateLabel.text = draft.endDate.toFormat("dd MMMM yyyy")
    }
}
