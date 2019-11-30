//
//  AssetActionConfirmationViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetActionConfirmationViewModel {
    func configure(_ view: AssetActionConfirmationView, with draft: AssetAlertDraft) {
        view.titleLabel.text = draft.title
        view.assetDisplayView.assetIndexLabel.text = draft.assetDetail.index
        view.assetDisplayView.assetNameLabel.text = draft.assetDetail.assetName
        view.assetDisplayView.assetCodeLabel.text = draft.assetDetail.unitName
        view.actionButton.setTitle(draft.actionTitle, for: .normal)
        configureAttributedText(in: view, with: draft)
    }
    
    private func configureAttributedText(in view: AssetActionConfirmationView, with draft: AssetAlertDraft) {
        guard let unitName = draft.assetDetail.unitName,
            let detailText = draft.detail else {
            view.detailLabel.text = draft.detail
            return
        }
        
        let range = (detailText as NSString).range(of: unitName)
        let attributedString = NSMutableAttributedString(string: detailText)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: SharedColors.purple, range: range)
        view.detailLabel.attributedText = attributedString
    }
}
