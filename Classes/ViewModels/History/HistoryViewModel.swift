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
    }
    
    func configureForAlgos(_ view: HistoryView) {
        view.assetSelectionView.detailLabel.text = "asset-algos-title".localized
    }

    func configure(_ view: HistoryView, with assetDetail: AssetDetail) {
        let nameText = (assetDetail.assetName ?? "").attributed()
        let codeText = "(\(assetDetail.unitName ?? ""))".attributed([.textColor(SharedColors.purple)])
        view.assetSelectionView.detailLabel.attributedText = nameText + codeText
    }
}
