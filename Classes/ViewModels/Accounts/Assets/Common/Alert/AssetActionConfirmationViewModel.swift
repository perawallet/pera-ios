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
        view.assetDisplayView.assetIndexLabel.text = "\(draft.assetIndex)"
        view.actionButton.setTitle(draft.actionTitle, for: .normal)
        
        configure(view.assetDisplayView, with: draft)
        configureAttributedText(in: view, with: draft)
    }
    
    private func configureAttributedText(in view: AssetActionConfirmationView, with draft: AssetAlertDraft) {
        guard let detailText = draft.detail else {
            return
        }
        
        let attributedDetailText = NSMutableAttributedString(attributedString: detailText.attributed([.lineSpacing(1.2)]))
        
        guard let assetDetail = draft.assetDetail,
            let unitName = assetDetail.unitName, !unitName.isEmptyOrBlank else {
            view.detailLabel.attributedText = attributedDetailText
            return
        }
        
        let range = (detailText as NSString).range(of: unitName)
        attributedDetailText.addAttribute(NSAttributedString.Key.foregroundColor, value: SharedColors.primary, range: range)
        attributedDetailText.addAttribute(NSAttributedString.Key.foregroundColor, value: SharedColors.primary, range: range)
        view.detailLabel.attributedText = attributedDetailText
    }
    
    func configure(_ view: AssetDisplayView, with draft: AssetAlertDraft) {
        guard let assetDetail = draft.assetDetail else {
            return
        }
        
        view.verifiedImageView.isHidden = !assetDetail.isVerified
        
        let displayNames = assetDetail.getDisplayNames()
        
        if displayNames.0.isUnknown() {
            view.assetCodeLabel.font = UIFont.font(withWeight: .semiBoldItalic(size: 40.0))
            view.assetCodeLabel.textColor = SharedColors.secondary
            view.assetCodeLabel.text = displayNames.0
        } else {
            view.assetNameLabel.text = displayNames.0
            view.assetCodeLabel.text = displayNames.1
        }
    }
}
