// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  AlgorandNotification.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class AlgorandNotification: ALGResponseModel {
    var debugData: Data?

    let badge: Int?
    let alert: String?
    let details: NotificationDetail?
    let sound: String?

    init(_ apiModel: APIModel = APIModel()) {
        self.badge = apiModel.badge
        self.alert = apiModel.alert
        self.details = apiModel.custom.unwrap(NotificationDetail.init)
        self.sound = apiModel.sound
    }
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
        case .broadcast:
            return nil
        default:
            return nil
        }
    }
}

extension AlgorandNotification {
    struct APIModel: ALGAPIModel {
        let badge: Int?
        let alert: String?
        let custom: NotificationDetail.APIModel?
        let sound: String?

        init() {
            self.badge = nil
            self.alert = nil
            self.custom = nil
            self.sound = nil
        }
    }
}
