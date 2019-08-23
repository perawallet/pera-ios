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
        view.accountSelectionView.detailLabel.text = draft.account.name
        view.accountSelectionView.set(amount: draft.account.amount.toAlgos)
        
        view.startDateDisplayView.detailLabel.text = draft.startDate.toFormat("dd MMMM yyyy")
        view.endDateDisplayView.detailLabel.text = draft.endDate.toFormat("dd MMMM yyyy")
    }
}
