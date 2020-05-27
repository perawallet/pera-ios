//
//  PushNotificationController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 5.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import UserNotifications
import NotificationBannerSwift

class PushNotificationController: NSObject {
    var token: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: Persistence.DefaultsDeviceTokenKey)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: Persistence.DefaultsDeviceTokenKey)
        }
    }
    
    private var api: API
    
    init(api: API) {
        self.api = api
    }
}

// MARK: Authentication

extension PushNotificationController {
    func requestAuthorization() {
        if UIApplication.shared.isRegisteredForRemoteNotifications {
            return
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { isGranted, _ in
            if !isGranted {
                return
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func authorizeDevice(with pushToken: String) {
        token = pushToken
        registerDevice()
    }
    
    func registerDevice() {
        guard let accounts = api.session.applicationConfiguration?.authenticatedUser()?.accounts else {
            return
        }
        
        let draft = DeviceRegistrationDraft(pushToken: token, accounts: accounts.map { $0.address })
        api.registerDevice(with: draft)
    }
    
    func revokeDevice() {
        UIApplication.shared.unregisterForRemoteNotifications()
        
        guard let token = token else {
            return
        }
        
        self.token = nil
        
        let draft = DeviceDeletionDraft(pushToken: token)
        api.unregisterDevice(with: draft)
    }
}

// MARK: Foreground

extension PushNotificationController {
    func show(with notificationDetail: NotificationDetail, then handler: EmptyHandler? = nil) {
        guard let notificationType = notificationDetail.notificationType else {
            return
        }
        
        switch notificationType {
        case .transactionSent,
             .assetTransactionSent:
            displaySentNotification(with: notificationDetail, then: handler)
        case .transactionReceived,
             .assetTransactionReceived:
            displayReceivedNotification(with: notificationDetail, then: handler)
        case .transactionFailed,
             .assetTransactionFailed:
            displaySentNotification(with: notificationDetail, isFailed: true, then: handler)
        default:
            break
        }
    }
    
    private func displaySentNotification(
        with notificationDetail: NotificationDetail,
        isFailed: Bool = false,
        then handler: EmptyHandler? = nil
    ) {
        guard let receiverAddress = notificationDetail.receiverAddress,
            let senderAddress = notificationDetail.senderAddress,
            let amount = notificationDetail.amount else {
                return
        }
        
        let isAssetTransaction = notificationDetail.asset != nil
        
        let receiverName = api.session.authenticatedUser?.account(address: receiverAddress)?.name ?? receiverAddress
        
        if let senderAccount = api.session.authenticatedUser?.account(address: senderAddress) {
            Contact.fetchAll(entity: Contact.entityName, with: NSPredicate(format: "address = %@", receiverAddress)) { response in
                switch response {
                case let .results(objects: objects):
                    guard let results = objects as? [Contact] else {
                        return
                    }
                    
                    var message: String
                    
                    if isAssetTransaction {
                        let name = notificationDetail.asset?.name ?? ""
                        let code = notificationDetail.asset?.code ?? ""
                        let fractionDecimals = notificationDetail.asset?.fractionDecimals ?? 0
                        let amountText = amount.toFractionStringForLabel(fraction: fractionDecimals) ?? ""
                        message = String(
                            format: isFailed ? "notification-sent-failed".localized : "notification-sent-success".localized,
                            "\(amountText) \(name) (\(code))",
                            senderAccount.name,
                            results.first?.name ?? receiverName
                        )
                    } else {
                        message = String(
                            format: isFailed ? "notification-sent-failed".localized : "notification-sent-success".localized,
                            "\(amount)",
                            senderAccount.name,
                            results.first?.name ?? receiverName
                        )
                    }
                    self.showNotificationMessage(message, then: handler)
                default:
                    var message: String
                    
                    if isAssetTransaction {
                        let name = notificationDetail.asset?.name ?? ""
                        let code = notificationDetail.asset?.code ?? ""
                        let fractionDecimals = notificationDetail.asset?.fractionDecimals ?? 0
                        let amountText = amount.toFractionStringForLabel(fraction: fractionDecimals) ?? ""
                        message = String(
                            format: isFailed ? "notification-sent-failed".localized : "notification-sent-success".localized,
                            "\(amountText) \(name) (\(code))",
                            senderAccount.name,
                            receiverName
                        )
                    } else {
                        message = String(
                            format: isFailed ? "notification-sent-failed".localized : "notification-sent-success".localized,
                            "\(amount)",
                            senderAccount.name,
                            receiverName
                        )
                    }
                    self.showNotificationMessage(message, then: handler)
                }
            }
        }
    }
    
    private func displayReceivedNotification(with notificationDetail: NotificationDetail, then handler: EmptyHandler? = nil) {
        guard let receiverAddress = notificationDetail.receiverAddress,
            let senderAddress = notificationDetail.senderAddress,
            let amount = notificationDetail.amount else {
                return
        }
        
        let isAssetTransaction = notificationDetail.asset != nil
        
        let senderName = api.session.authenticatedUser?.account(address: senderAddress)?.name ?? senderAddress
        
        if let receiverAccount = api.session.authenticatedUser?.account(address: receiverAddress) {
            Contact.fetchAll(entity: Contact.entityName, with: NSPredicate(format: "address = %@", senderAddress)) { response in
                switch response {
                case let .results(objects: objects):
                    guard let results = objects as? [Contact] else {
                        return
                    }
                    
                    var message: String
                    
                    if isAssetTransaction {
                        let name = notificationDetail.asset?.name ?? ""
                        let code = notificationDetail.asset?.code ?? ""
                        let fractionDecimals = notificationDetail.asset?.fractionDecimals ?? 0
                        let amountText = amount.toFractionStringForLabel(fraction: fractionDecimals) ?? ""
                        message = String(
                            format: "notification-received".localized,
                            "\(amountText) \(name) (\(code))",
                            receiverAccount.name,
                            results.first?.name ?? senderName
                        )
                    } else {
                        message = String(
                            format: "notification-received".localized,
                            "\(amount.toAlgos.toDecimalStringForLabel ?? "") Algos",
                            receiverAccount.name,
                            results.first?.name ?? senderName
                        )
                    }
                    self.showNotificationMessage(message, then: handler)
                default:
                    var message: String
                    
                    if isAssetTransaction {
                        let name = notificationDetail.asset?.name ?? ""
                        let code = notificationDetail.asset?.code ?? ""
                        let fractionDecimals = notificationDetail.asset?.fractionDecimals ?? 0
                        let amountText = amount.toFractionStringForLabel(fraction: fractionDecimals) ?? ""
                        message = String(
                            format: "notification-received".localized,
                            "\(amountText) \(name) (\(code))",
                            receiverAccount.name,
                            senderName
                        )
                    } else {
                        message = String(
                            format: "notification-received".localized,
                            "\(amount.toAlgos.toDecimalStringForLabel ?? "") Algos",
                            receiverAccount.name,
                            senderName
                        )
                    }
                    self.showNotificationMessage(message, then: handler)
                }
            }
        }
    }
}

// MARK: NotificationBannerSwift

extension PushNotificationController {
    func showNotificationMessage(_ title: String, then handler: EmptyHandler? = nil) {
        let banner = FloatingNotificationBanner(
            title: title,
            titleFont: UIFont.font(.overpass, withWeight: .semiBold(size: 14.0)),
            titleColor: .black,
            titleTextAlign: .left,
            colors: CustomBannerColors()
        )
        
        banner.duration = 3.0
        
        banner.show(
            edgeInsets: UIEdgeInsets(top: 20.0, left: 10.0, bottom: 0.0, right: 10.0),
            cornerRadius: 10.0,
            shadowColor: rgba(0.0, 0.0, 0.0, 0.1),
            shadowOpacity: 1.0,
            shadowBlurRadius: 6.0,
            shadowCornerRadius: 6.0,
            shadowOffset: UIOffset(horizontal: 0.0, vertical: 2.0)
        )
        
        banner.onTap = handler
    }
    
    func showFeedbackMessage(_ title: String, subtitle: String) {
        let banner = FloatingNotificationBanner(
            title: title,
            subtitle: subtitle,
            titleFont: UIFont.font(.overpass, withWeight: .semiBold(size: 15.0)),
            titleColor: UIColor.white,
            titleTextAlign: .left,
            subtitleFont: UIFont.font(.avenir, withWeight: .demiBold(size: 12.0)),
            subtitleColor: UIColor.white.withAlphaComponent(0.8),
            subtitleTextAlign: .left,
            leftView: UIImageView(image: img("icon-warning-circle")),
            style: .warning,
            colors: CustomBannerColors()
        )
        
        banner.duration = 3.0
        
        banner.show(
            edgeInsets: UIEdgeInsets(top: 20.0, left: 15.0, bottom: 0.0, right: 15.0),
            cornerRadius: 10.0,
            shadowColor: rgba(0.0, 0.0, 0.0, 0.1),
            shadowOpacity: 1.0,
            shadowBlurRadius: 6.0,
            shadowCornerRadius: 6.0,
            shadowOffset: UIOffset(horizontal: 0.0, vertical: 2.0)
        )
    }
}

// MARK: Storage

extension PushNotificationController {
    enum Persistence {
        static let DefaultsDeviceTokenKey = "DefaultsDeviceTokenKey"
    }
}

// MARK: BannerColorsProtocol

class CustomBannerColors: BannerColorsProtocol {
    internal func color(for style: BannerStyle) -> UIColor {
        switch style {
        case .warning:
            return rgb(0.94, 0.4, 0.4)
        default:
            return .white
        }
    }
}
