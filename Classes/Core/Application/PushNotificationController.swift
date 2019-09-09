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
    func show(with title: String, then handler: @escaping EmptyHandler) {
        let banner = FloatingNotificationBanner(
            title: title,
            subtitle: nil,
            titleFont: UIFont.font(.overpass, withWeight: .semiBold(size: 14.0)),
            titleColor: .black,
            titleTextAlign: .left,
            subtitleFont: nil,
            subtitleColor: nil,
            subtitleTextAlign: nil,
            leftView: nil,
            rightView: nil,
            style: .info,
            colors: CustomBannerColors(),
            iconPosition: .center
        )
        
        banner.show(
            queuePosition: .back,
            bannerPosition: .top,
            queue: .default,
            on: nil,
            edgeInsets: UIEdgeInsets(top: 20.0, left: 10.0, bottom: 0.0, right: 10.0),
            cornerRadius: 10.0,
            shadowColor: rgba(0.0, 0.0, 0.0, 0.1),
            shadowOpacity: 1.0,
            shadowBlurRadius: 6.0,
            shadowCornerRadius: 6.0,
            shadowOffset: UIOffset(horizontal: 0.0, vertical: 2.0),
            shadowEdgeInsets: nil
        )
        
        banner.onTap = handler
    }
}

// MARK: Storage

extension PushNotificationController {
    enum Persistence {
        static let DefaultsDeviceTokenKey = "DefaultsDeviceTokenKey"
    }
}

class CustomBannerColors: BannerColorsProtocol {
    internal func color(for style: BannerStyle) -> UIColor {
        switch style {
        default:
            return .white
        }
    }
}
