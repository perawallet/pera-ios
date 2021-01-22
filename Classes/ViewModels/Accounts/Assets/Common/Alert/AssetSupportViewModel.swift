//
//  AssetSupportViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetSupportViewModel {
    private(set) var title: String?
    private(set) var id: String?
    private(set) var detail: String?
    private(set) var assetDisplayViewModel: AssetDisplayViewModel?

    init(draft: AssetAlertDraft) {
        setTitle(from: draft)
        setId(from: draft)
        setDetail(from: draft)
        setAssetDisplayViewModel(from: draft)
    }

    private func setTitle(from draft: AssetAlertDraft) {
        title = draft.title
    }

    private func setId(from draft: AssetAlertDraft) {
        id = "\(draft.assetIndex)"
    }

    private func setDetail(from draft: AssetAlertDraft) {
        detail = draft.detail
    }

    private func setAssetDisplayViewModel(from draft: AssetAlertDraft) {
        assetDisplayViewModel = AssetDisplayViewModel(assetDetail: draft.assetDetail)
    }
}
