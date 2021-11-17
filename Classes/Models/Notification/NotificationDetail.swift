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
//  NotificationDetail.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class NotificationDetail: ALGAPIModel {
    let senderAddress: String?
    let receiverAddress: String?
    private let amount: UInt64?
    private let amountStr: String?
    let asset: NotificationAsset?
    let notificationType: NotificationType?

    init() {
        self.senderAddress = nil
        self.receiverAddress = nil
        self.amount = nil
        self.asset = nil
        self.notificationType = nil
    }
}

extension NotificationDetail {
    private enum CodingKeys:
        String,
        CodingKey {
        case senderAddress = "senderPublicKey"
        case receiverAddress = "receiverPublicKey"
        case amount
        case asset
        case notificationType
    }
}

enum NotificationType: String, ALGAPIModel {
    case transactionSent = "transaction-sent"
    case transactionReceived = "transaction-received"
    case transactionFailed = "transaction-failed"
    case assetTransactionSent = "asset-transaction-sent"
    case assetTransactionReceived = "asset-transaction-received"
    case assetTransactionFailed = "asset-transaction-failed"
    case assetSupportRequest = "asset-support-request"
    case assetSupportSuccess = "asset-support-success"
    case broadcast = "broadcast"

    init() {
        self = .transactionSent
    }
}
