//
//  AssetAlertDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

struct AssetAlertDraft {
    let account: Account
    let assetDetail: AssetDetail
    let title: String?
    let detail: String?
    let actionTitle: String?
    
    init(account: Account, assetDetail: AssetDetail, title: String? = nil, detail: String? = nil, actionTitle: String? = nil) {
        self.account = account
        self.assetDetail = assetDetail
        self.title = title
        self.detail = detail
        self.actionTitle = actionTitle
    }
}
