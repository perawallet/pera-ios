//
//  AssetAlertDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

struct AssetAlertDraft {
    let account: Account?
    let assetIndex: Int64
    var assetDetail: AssetDetail?
    let title: String?
    let detail: String?
    let actionTitle: String?
    
    init(
        account: Account?,
        assetIndex: Int64,
        assetDetail: AssetDetail?,
        title: String? = nil,
        detail: String? = nil,
        actionTitle: String? = nil
    ) {
        self.account = account
        self.assetIndex = assetIndex
        self.assetDetail = assetDetail
        self.title = title
        self.detail = detail
        self.actionTitle = actionTitle
    }
}
