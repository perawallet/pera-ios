//
//  AnalyticsEvent.swift

import Foundation

typealias AnalyticsParameters = [AnalyticsParameter: Any]

protocol AnalyticsEvent {
    var key: AnalyticsEventKey { get }
    var params: AnalyticsParameters? { get }
}

extension AnalyticsEvent {
    var params: AnalyticsParameters? {
        return nil
    }
}

enum AnalyticsEventKey: String {
    case currencyChange = "currency_change"
    case rekey = "rekey"
    case transaction = "transaction"
    case register = "register"
    case tabSend = "tap_tab_send"
    case detailSend = "tap_asset_detail_send"
    case showQRCopy = "tap_show_qr_copy"
    case showQRShare = "tap_show_qr_share"
    case showQRShareComplete = "tap_show_qr_share_complete"
    case tabReceive = "tap_tab_receive"
    case detailReceive = "tap_asset_detail_receive"
    case assetDetail = "asset_detail_asset"
    case assetDetailChange = "asset_detail_asset_change"
    case notificationFilter = "notification_filter_change"
}

enum AnalyticsParameter: String {
    case id = "id"
    case address = "address"
    case type = "type"
    case amount = "amount"
    case isMax = "is_max"
    case accountType = "account_type"
    case assetId = "asset_id"
    case sender = "sender"
    case unsignedTransaction = "unsigned_transaction"
    case signedTransaction = "signed_transaction"
    case isReceivingNotifications = "is_receiving_notifications"
}
