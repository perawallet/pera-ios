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
        view.actionButton.setTitle(draft.actionTitle, for: .normal)
        
        let displayNames = draft.assetDetail.getDisplayNames()
        
        if displayNames.0.isUnknown() {
            view.assetDisplayView.assetCodeLabel.font = UIFont.font(.avenir, withWeight: .demiBoldItalic(size: 40.0))
            view.assetDisplayView.assetCodeLabel.textColor = SharedColors.orange
            view.assetDisplayView.assetCodeLabel.text = displayNames.0
        } else {
            view.assetDisplayView.assetNameLabel.text = displayNames.0
            view.assetDisplayView.assetCodeLabel.text = displayNames.1
        }
        
        configureAttributedText(in: view, with: draft)
    }
    
    private func configureAttributedText(in view: AssetActionConfirmationView, with draft: AssetAlertDraft) {
        guard  let detailText = draft.detail,
            let unitName = draft.assetDetail.unitName, !unitName.isEmptyOrBlank else {
            view.detailLabel.text = draft.detail
            return
        }
        
        let range = (detailText as NSString).range(of: unitName)
        let attributedString = NSMutableAttributedString(string: detailText)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: SharedColors.purple, range: range)
        view.detailLabel.attributedText = attributedString
    }
}
