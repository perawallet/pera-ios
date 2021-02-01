//
//  NotificationDetail.swift

import Magpie

class NotificationDetail: Model {
    let senderAddress: String?
    let receiverAddress: String?
    let amount: Int64?
    let asset: NotificationAsset?
    let notificationType: NotificationType?
}

extension NotificationDetail {
    enum CodingKeys: String, CodingKey {
        case senderAddress = "sender_public_key"
        case receiverAddress = "receiver_public_key"
        case amount = "amount"
        case asset = "asset"
        case notificationType = "notification_type"
    }
}

enum NotificationType: String, Model {
    case transactionSent = "transaction-sent"
    case transactionReceived = "transaction-received"
    case transactionFailed = "transaction-failed"
    case assetTransactionSent = "asset-transaction-sent"
    case assetTransactionReceived = "asset-transaction-received"
    case assetTransactionFailed = "asset-transaction-failed"
    case assetSupportRequest = "asset-support-request"
    case assetSupportSuccess = "asset-support-success"
}
