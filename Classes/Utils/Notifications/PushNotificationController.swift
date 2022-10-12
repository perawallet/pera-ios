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
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: Persistence.DefaultsDeviceTokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Persistence.DefaultsDeviceTokenKey)
            UserDefaults.standard.synchronize()
        }
    }

    private lazy var currencyFormatter = CurrencyFormatter()
    
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
        sendDeviceDetails()
    }
    
    func sendDeviceDetails(
        completion handler: ((HIPNetworkError<HIPAPIError>?) -> Void)? = nil
    ) {
        guard let user = session.authenticatedUser else {
            return
        }
        
        if let deviceId = user.getDeviceId(on: api.network) {
            updateDevice(with: deviceId, for: user, completion: handler)
        } else {
            registerDevice(for: user, completion: handler)
        }
    }
    
    private func updateDevice(
        with id: String,
        for user: User,
        completion handler: ((HIPNetworkError<HIPAPIError>?) -> Void)? = nil
    ) {
        let draft = DeviceUpdateDraft(id: id, pushToken: token, app: target.app, accounts: user.accounts.map(\.address))
        api.updateDevice(draft) { response in
            switch response {
            case let .success(device):
                self.session.authenticatedUser?.setDeviceID(
                    device.id,
                    on: self.api.network
                )
                handler?(nil)
            case let .failure(apiError, apiErrorDetail):
                if let errorType = apiErrorDetail?.type,
                   errorType == AlgorandError.ErrorType.deviceAlreadyExists.rawValue {
                    self.registerDevice(for: user, completion: handler)
                } else {
                    let error = HIPNetworkError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                    handler?(error)
                }
            }
        }
    }
    
    private func registerDevice(
        for user: User,
        completion handler: ((HIPNetworkError<HIPAPIError>?) -> Void)? = nil
    ) {
        let draft = DeviceRegistrationDraft(pushToken: token, app: target.app, accounts: user.accounts.map(\.address))
        api.registerDevice(draft) { response in
            switch response {
            case let .success(device):
                self.session.authenticatedUser?.setDeviceID(
                    device.id,
                    on: self.api.network
                )
                handler?(nil)
            case let .failure(apiError, apiErrorDetail):
                let error = HIPNetworkError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                handler?(error)
            }
        }
    }
    
    func unregisterDevice(
        from network: ALGAPI.Network
    ) {
        guard
            let user = session.authenticatedUser,
            let id = user.getDeviceId(on: network)
        else {
            return
        }
        
        let draft = DeviceUpdateDraft(
            id: id,
            pushToken: nil,
            app: target.app,
            accounts: user.accounts.map(\.address)
        )
        api.unregisterDevice(
            draft,
            from: network
        ) { _ in }
    }
    
    func revokeDevice(
        completion handler: @escaping BoolHandler
    ) {
        UIApplication.shared.unregisterForRemoteNotifications()
        if let token = token {
            self.token = nil
            let draft = DeviceDeletionDraft(pushToken: token)
            api.revokeDevice(draft) { response in
                switch response {
                case .success:
                    handler(true)
                case .failure:
                    handler(false)
                }
            }
            return
        }

        handler(true)
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
             .assetTransactionSent,
             .transactionReceived,
             .assetTransactionReceived,
             .transactionFailed,
             .assetTransactionFailed:
            presentBanner(
                for: notification,
                action: handler
            )
        case .assetSupportSuccess:
            presentBanner(for: notification)
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

    private func presentBanner(
        for notification: AlgorandNotification,
        action handler: EmptyHandler? = nil
    ) {
        guard let message = notification.detail?.message else {
            return
        }

        bannerController?.presentNotification(
            message,
            handler
        )
    }
}

// MARK: Storage

extension PushNotificationController {
    enum Persistence {
        static let DefaultsDeviceTokenKey = "DefaultsDeviceTokenKey"
    }
}
