//
//  AssetSupportViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetSupportViewModel {
    func configure(_ view: AssetSupportView, with draft: AssetAlertDraft) {
        view.titleLabel.text = draft.title
        view.assetDisplayView.assetIndexLabel.text = "\(draft.assetIndex)"
        configure(view.assetDisplayView, with: draft)
        view.detailLabel.text = draft.detail
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
