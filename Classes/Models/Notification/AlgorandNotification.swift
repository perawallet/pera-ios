//
//  AlgorandNotification.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 10.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class AlgorandNotification: Model {
    let badge: Int?
    let alert: String?
    let details: NotificationDetail?
    let sound: String?
}

extension AlgorandNotification {
    func getAccountId() -> String? {
        guard let notificationDetails = details,
              let notificationType = notificationDetails.notificationType else {
                return nil
        }

        switch notificationType {
        case .transactionReceived,
             .assetTransactionReceived:
            return notificationDetails.receiverAddress
        case .transactionSent,
             .assetTransactionSent:
            return notificationDetails.senderAddress
        case .assetSupportRequest:
            return notificationDetails.receiverAddress
        case .assetSupportSuccess:
            return notificationDetails.receiverAddress
        default:
            return nil
        }
    }
}

extension AlgorandNotification {
    enum CodingKeys: String, CodingKey {
        case badge = "badge"
        case alert = "alert"
        case details = "custom"
        case sound = "sound"
    }
}
