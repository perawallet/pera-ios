// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ALGAnalyticsEvent.swift

import Foundation
import MacaroonVendors
import UIKit

protocol ALGAnalyticsEvent: AnalyticsEvent
where
    Self.Name == ALGAnalyticsEventName,
    Self.Metadata == ALGAnalyticsMetadata {}

/// <note>
/// Naming convention:
/// Action-related name should be used, i.e. either showQRCopy (active) or wcSessionApproved (passive)
/// Sort:
/// Alphabetical order
enum ALGAnalyticsEventName:
    String,
    AnalyticsEventName {
    case assetDetail
    case assetDetailChange
    case currencyChange
    case detailReceive
    case detailSend
    case notificationFilter
    case register
    case rekey
    case showQRCopy
    case showQRShare
    case showQRShareComplete
    case tabBuyAlgo
    case tabReceive
    case tabSend
    case transaction
    case wcSessionApproved
    case wcSessionDisconnected
    case wcSessionRejected
    case wcTransactionConfirmed
    case wcTransactionDeclined
}

extension ALGAnalyticsEventName {
    var rawValue: String {
        /// Sort:
        /// Alphabetical order by `rawName`.
        let rawName: String
        switch self {
        case .assetDetail: rawName = "asset_detail_asset"
        case .assetDetailChange: rawName = "asset_detail_asset_change"
        case .currencyChange: rawName = "currency_change"
        case .detailReceive: rawName = "tap_asset_detail_receive"
        case .detailSend: rawName = "tap_asset_detail_send"
        case .notificationFilter: rawName = "notification_filter_change"
        case .register: rawName = "register"
        case .rekey: rawName = "rekey"
        case .showQRCopy: rawName = "tap_show_qr_copy"
        case .showQRShare: rawName = "tap_show_qr_share"
        case .showQRShareComplete: rawName = "tap_show_qr_share_complete"
        case .tabBuyAlgo: rawName = "tap_tab_buy_algo"
        case .tabReceive: rawName = "tap_tab_receive"
        case .tabSend: rawName = "tap_tab_send"
        case .transaction: rawName = "transaction"
        case .wcSessionApproved: rawName = "wc_session_approved"
        case .wcSessionDisconnected: rawName = "wc_session_disconnected"
        case .wcSessionRejected: rawName = "wc_session_rejected"
        case .wcTransactionConfirmed: rawName = "wc_transaction_confirmed"
        case .wcTransactionDeclined: rawName = "wc_transaction_declined"
        }

        let isTestnet = UIApplication.shared.appConfiguration?.api.isTestNet ?? false
        return isTestnet ? "testnet_\(rawName)" : rawName
    }
}
