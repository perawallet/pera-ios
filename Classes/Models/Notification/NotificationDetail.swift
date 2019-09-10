//
//  NotificationDetail.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 10.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct NotificationDetail: Model {
    let address: String?
    let amount: Double?
    let notificationType: Type?
}

extension NotificationDetail {
    enum CodingKeys: String, CodingKey {
        case address = "public_key"
        case amount = "amount"
        case notificationType = "notification_type"
    }
}

extension NotificationDetail {
    enum `Type`: String, Model {
        case transactionSent = "transaction-sent"
        case transactionReceived = "transaction-received"
        case transactionFailed = "transaction-failed"
    }
}
