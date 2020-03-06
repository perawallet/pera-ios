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
        
        if account.type == .ledger {
            view.accountSelectionView.setLedgerAccount()
        } else {
            view.accountSelectionView.setStandardAccount()
        }
    }
    
    func configureForAlgos(_ view: HistoryView) {
        view.assetSelectionView.detailLabel.text = "asset-algos-title".localized
        view.assetSelectionView.verifiedImageView.isHidden = false
    }

    func configure(_ view: HistoryView, with assetDetail: AssetDetail) {
        view.assetSelectionView.detailLabel.attributedText = assetDetail.assetDisplayName()
        view.assetSelectionView.verifiedImageView.isHidden = !assetDetail.isVerified
    }
}
