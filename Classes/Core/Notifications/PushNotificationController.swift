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
        if let token = token,
            let accounts = api.session.applicationConfiguration?.authenticatedUser()?.accounts {
            let accountAddresses = accounts.map { $0.address }
            let draft = DeviceRegistrationDraft(pushToken: token, accounts: accountAddresses)
            api.registerDevice(with: draft)
        }
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
        case .transactionSent:
            displaySentNotification(with: notificationDetail, then: handler)
        case .transactionReceived:
            displayReceivedNotification(with: notificationDetail, then: handler)
        case .transactionFailed:
            displaySentNotification(with: notificationDetail, isFailed: true, then: handler)
        }
    }
    
    private func displaySentNotification(
        with notificationDetail: NotificationDetail,
        isFailed: Bool = false,
        then handler: EmptyHandler? = nil
    ) {
        guard let receiverAddress = notificationDetail.receiverAddress,
            let senderAddress = notificationDetail.senderAddress else {
                return
        }
        
        if let amount = notificationDetail.amount?.toAlgos {
            if let senderAccount = api.session.authenticatedUser?.account(address: senderAddress) {
                Contact.fetchAll(entity: Contact.entityName, with: NSPredicate(format: "address = %@", receiverAddress)) { response in
                    switch response {
                    case let .results(objects: objects):
                        guard let results = objects as? [Contact] else {
                            return
                        }
                        
                        let message = String(
                            format: isFailed ? "notification-sent-failed".localized : "notification-sent-success".localized,
                            "\(amount)",
                            senderAccount.name ?? senderAddress,
                            results.first?.name ?? receiverAddress
                        )
                        
                        self.showNotificationMessage(message, then: handler)
                    default:
                        let message = String(
                            format: isFailed ? "notification-sent-failed".localized : "notification-sent-success".localized,
                            "\(amount)",
                            (senderAccount.name ?? senderAddress),
                            receiverAddress
                        )
                        
                        self.showNotificationMessage(message, then: handler)
                    }
                }
            }
        }
    }
    
    private func displayReceivedNotification(with notificationDetail: NotificationDetail, then handler: EmptyHandler? = nil) {
        guard let receiverAddress = notificationDetail.receiverAddress,
            let senderAddress = notificationDetail.senderAddress else {
                return
        }
        
        if let amount = notificationDetail.amount?.toAlgos {
            if let receiverAccount = api.session.authenticatedUser?.account(address: receiverAddress) {
                Contact.fetchAll(entity: Contact.entityName, with: NSPredicate(format: "address = %@", senderAddress)) { response in
                    switch response {
                    case let .results(objects: objects):
                        guard let results = objects as? [Contact] else {
                            return
                        }
                        
                        let message = String(
                            format: "notification-received".localized,
                            "\(amount)",
                            receiverAccount.name ?? receiverAddress,
                            results.first?.name ?? senderAddress
                        )
                        
                        self.showNotificationMessage(message, then: handler)
                    default:
                        let message = String(
                            format: "notification-received".localized,
                            "\(amount)",
                            (receiverAccount.name ?? receiverAddress),
                            senderAddress
                        )
                        self.showNotificationMessage(message, then: handler)
                    }
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
            titleTextAlign: .center,
            subtitleFont: UIFont.font(.avenir, withWeight: .demiBold(size: 12.0)),
            subtitleColor: UIColor.white.withAlphaComponent(0.8),
            subtitleTextAlign: .center,
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
