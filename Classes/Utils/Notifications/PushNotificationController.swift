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

//
//  PushNotificationController.swift

import Foundation
import MagpieExceptions
import MagpieHipo
import UIKit
import UserNotifications

class PushNotificationController: NSObject {
    private lazy var deviceRegistrationController = DeviceRegistrationController(
        target: target,
        session: session,
        api: api
    )

    private lazy var currencyFormatter = CurrencyFormatter()

    var token: String? {
        return deviceRegistrationController.token
    }
    
    private let target: ALGAppTarget
    private let session: Session
    private let api: ALGAPI
    private let bannerController: BannerController?
    
    init(
        target: ALGAppTarget,
        session: Session,
        api: ALGAPI,
        bannerController: BannerController?
    ) {
        self.target = target
        self.session = session
        self.api = api
        self.bannerController = bannerController
    }
}

// MARK: Authentication

extension PushNotificationController {
    func requestAuthorization() {
        deviceRegistrationController.requestAuthorization()
    }
    
    func authorizeDevice(with pushToken: String) {
        deviceRegistrationController.authorizeDevice(with: pushToken)
    }
    
    func sendDeviceDetails(
        completion handler: ((HIPNetworkError<HIPAPIError>?) -> Void)? = nil
    ) {
        deviceRegistrationController.sendDeviceDetails(completion: handler)
    }
    
    private func updateDevice(
        with id: String,
        for user: User,
        completion handler: ((HIPNetworkError<HIPAPIError>?) -> Void)? = nil
    ) {
        deviceRegistrationController.updateDevice(
            with: id,
            for: user,
            completion: handler
        )
    }
    
    private func registerDevice(
        for user: User,
        completion handler: ((HIPNetworkError<HIPAPIError>?) -> Void)? = nil
    ) {
        deviceRegistrationController.registerDevice(
            for: user,
            completion: handler
        )
    }
    
    func unregisterDevice(
        from network: ALGAPI.Network
    ) {
        deviceRegistrationController.unregisterDevice(from: network)
    }
    
    func revokeDevice(
        completion handler: @escaping BoolHandler
    ) {
        deviceRegistrationController.revokeDevice(completion: handler)
    }
}

// MARK: Foreground

extension PushNotificationController {
    func present(
        notification: AlgorandNotification,
        action handler: EmptyHandler? = nil
    ) {
        guard let notificationDetail = notification.detail else {
            present(idleNotification: notification)
            return
        }

        switch notificationDetail.type {
        case .transactionSent,
             .assetTransactionSent:
            present(
                notificationForSentTransactionsWith: notificationDetail,
                failure: false,
                action: handler
            )
        case .transactionReceived,
             .assetTransactionReceived:
            present(
                notificationForReceivedTransactionWith: notificationDetail,
                action: handler
            )
        case .transactionFailed,
             .assetTransactionFailed:
            present(
                notificationForSentTransactionsWith: notificationDetail,
                failure: true,
                action: handler
            )
        case .assetSupportSuccess:
            present(notificationForSupportedAssetWith: notificationDetail)
        default:
            present(idleNotification: notification)
        }
    }
    
    private func present(
        idleNotification notification: AlgorandNotification
    ) {
        if let alert = notification.alert {
            bannerController?.presentNotification(alert)
        }
    }
    
    private func present(
        notificationForSentTransactionsWith detail: NotificationDetail,
        failure: Bool = false,
        action handler: EmptyHandler? = nil
    ) {
        guard
            let authenticatedUser = session.authenticatedUser,
            let receiverAddress = detail.receiverAddress,
            let senderAddress = detail.senderAddress,
            let senderName = authenticatedUser.account(address: senderAddress)?.name
        else {
            return
        }
        
        Contact.fetchAll(
            entity: Contact.entityName,
            with: NSPredicate(format: "address = %@", receiverAddress)
        ) { [weak self] response in
            guard let self = self else { return }
            
            let receiverAccount = authenticatedUser.account(address: receiverAddress)
            let defaultReceiverName = receiverAccount?.name ?? receiverAddress
            let amount = detail.amount
            
            let receiverName: String
            if case .results(let objects) = response {
                receiverName = (objects as? [Contact])?.first?.name ?? defaultReceiverName
            } else {
                receiverName = defaultReceiverName
            }
            
            let transactionAmountText: String
            if let asset = detail.asset {
                let assetFraction = asset.fractionDecimals.someInt

                /// <todo>
                /// Not sure we need this constraint, because the final number should be sent to the
                /// formatter unless the number itself is modified.
                var constraintRules = CurrencyFormattingContextRules()
                constraintRules.maximumFractionDigits = assetFraction

                self.currencyFormatter.formattingContext = .standalone(constraints: constraintRules)
                self.currencyFormatter.currency = nil

                let assetName = asset.name.someString
                let assetCode = asset.code.someString
                let amount = amount.assetAmount(fromFraction: assetFraction)
                let amountText = self.currencyFormatter.format(amount)

                transactionAmountText = "\(amountText.someString) \(assetName) (\(assetCode))"
            } else {
                self.currencyFormatter.formattingContext = .standalone()
                self.currencyFormatter.currency = AlgoLocalCurrency()

                let text = self.currencyFormatter.format(amount.toAlgos)

                transactionAmountText = text.someString
            }
            
            let format = failure
                ? "notification-sent-failed".localized
                : "notification-sent-success".localized
            let message = String(
                format: format,
                transactionAmountText,
                senderName,
                receiverName
            )
            
            self.bannerController?.presentNotification(
                message,
                handler
            )
        }
    }
    
    private func present(
        notificationForReceivedTransactionWith detail: NotificationDetail,
        action handler: EmptyHandler? = nil
    ) {
        guard
            let authenticatedUser = session.authenticatedUser,
            let senderAddress = detail.senderAddress,
            let receiverAddress = detail.receiverAddress,
            let receiverName = authenticatedUser.account(address: receiverAddress)?.name
        else {
            return
        }
        
        Contact.fetchAll(
            entity: Contact.entityName,
            with: NSPredicate(format: "address = %@", senderAddress)
        ) { [weak self] response in
            guard let self = self else { return }
            
            let senderAccount = authenticatedUser.account(address: senderAddress)
            let defaultSenderName = senderAccount?.name ?? senderAddress
            let amount = detail.amount
            
            let senderName: String
            if case .results(let objects) = response {
                senderName = (objects as? [Contact])?.first?.name ?? defaultSenderName
            } else {
                senderName = defaultSenderName
            }

            let transactionAmountText: String
            if let asset = detail.asset {
                let assetFraction = asset.fractionDecimals.someInt

                /// <todo>
                /// Not sure we need this constraint, because the final number should be sent to the
                /// formatter unless the number itself is modified.
                var constraintRules = CurrencyFormattingContextRules()
                constraintRules.maximumFractionDigits = assetFraction

                self.currencyFormatter.formattingContext = .standalone(constraints: constraintRules)
                self.currencyFormatter.currency = nil

                let assetName = asset.name.someString
                let assetCode = asset.code.someString
                let amount = amount.assetAmount(fromFraction: assetFraction)
                let amountText = self.currencyFormatter.format(amount)

                transactionAmountText = "\(amountText.someString) \(assetName) (\(assetCode))"
            } else {
                self.currencyFormatter.formattingContext = .standalone()
                self.currencyFormatter.currency = AlgoLocalCurrency()

                let text = self.currencyFormatter.format(amount.toAlgos)

                transactionAmountText = text.someString
            }
            
            let message = String(
                format: "notification-received".localized,
                transactionAmountText,
                receiverName,
                senderName
            )

            self.bannerController?.presentNotification(
                message,
                handler
            )
        }
    }
    
    private func present(
        notificationForSupportedAssetWith detail: NotificationDetail
    ) {
        guard
            let senderAddress = detail.senderAddress,
            let asset = detail.asset
        else {
            return
        }
        
        Contact.fetchAll(
            entity: Contact.entityName,
            with: NSPredicate(format: "address = %@", senderAddress)
        ) { [weak self] response in
            guard let self = self else { return }
            
            let assetName = asset.name.someString
            let assetCode = asset.code.someString
            
            let senderName: String
            if case .results(let objects) = response {
                senderName = (objects as? [Contact])?.first?.name ?? senderAddress
            } else {
                senderName = senderAddress
            }
            
            let message = String(
                format: "notification-support-success".localized(
                    params: senderName,
                    "\(assetName) (\(assetCode))"
                )
            )

            self.bannerController?.presentNotification(message)
        }
    }
}
