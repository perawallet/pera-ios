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
        view.startDateDisplayView.detailLabel.text = draft.startDate.toFormat("dd MMMM yyyy")
        view.endDateDisplayView.detailLabel.text = draft.endDate.toFormat("dd MMMM yyyy")
        
        if draft.isAlgoSelected {
            view.assetSelectionView.detailLabel.text = "asset-algos-title".localized
        } else {
            guard let assetDetail = draft.assetDetail else {
                return
            }
            
            view.assetSelectionView.detailLabel.attributedText = assetDetail.assetDisplayName()
        }
    }
}
