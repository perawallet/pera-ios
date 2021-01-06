//
//  AnalyticsScreen.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.10.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

protocol AnalyticsScreen {
    var name: AnalyticsScreenName? { get }
    var params: AnalyticsParameters? { get }
}

extension AnalyticsScreen {
    var params: AnalyticsParameters? {
        return nil
    }
}

enum AnalyticsScreenName: String {
    case assetDetail = "screen_asset_detail"
    case accounts = "screen_accounts"
    case showQR = "screen_show_qr"
    case contactDetail = "screen_contact_detail"
    case contacts = "screen_contacts"
    case transactionDetail = "screen_transaction_detail"
}
