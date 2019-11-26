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
        view.assetDisplayView.assetNameLabel.text = draft.assetDetail.assetName
        view.assetDisplayView.assetCodeLabel.text = draft.assetDetail.unitName
        view.detailLabel.text = draft.detail
        view.actionButton.setTitle(draft.actionTitle, for: .normal)
    }
}
