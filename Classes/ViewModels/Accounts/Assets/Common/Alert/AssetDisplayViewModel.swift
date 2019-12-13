//
//  AssetSupportAlertViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetSupportAlertViewModel {
    func configure(_ view: AssetSupportAlertView, with draft: AssetAlertDraft) {
        view.titleLabel.text = draft.title
        configure(view.assetDisplayView, with: draft)
        view.detailLabel.text = draft.detail
    }
    
    func configure(_ view: AssetCancellableSupportAlertView, with draft: AssetAlertDraft) {
        configure(view.assetDisplayView, with: draft)
    }
    
    private func configure(_ view: AssetDisplayView, with draft: AssetAlertDraft) {
        let displayNames = draft.assetDetail.getDisplayNames(isDisplayingBrackets: false)
        
        view.assetIndexLabel.text = draft.assetDetail.index
        if displayNames.0.isUnknown() {
            view.assetCodeLabel.font = UIFont.font(.avenir, withWeight: .demiBoldItalic(size: 40.0))
            view.assetCodeLabel.textColor = SharedColors.orange
            view.assetCodeLabel.text = displayNames.0
        } else {
            view.assetNameLabel.text = displayNames.0
            view.assetCodeLabel.text = displayNames.1
        }
    }
}
