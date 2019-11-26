//
//  AssetDisplayViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetDisplayViewModel {
    func configure(_ view: AssetDisplayView, with draft: AssetAlertDraft) {
        view.assetNameLabel.text = draft.assetDetail.assetName
        view.assetCodeLabel.text = draft.assetDetail.unitName
    }
}
