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
//  DeepLinkRouter.swift

import UIKit

class DeepLinkRouter {
    var rootViewController: RootViewController {
        return router.rootViewController
    }

    private unowned let router: Router
    private unowned let appConfiguration: AppConfiguration

    private var isInitializedFromDeeplink = false

    init(
        router: Router,
        appConfiguration: AppConfiguration
    ) {
        self.router = router
        self.appConfiguration = appConfiguration
    }

    @discardableResult
    private func openLoginScreen(with route: Screen? = nil) -> UIViewController? {
        return rootViewController.open(
           .choosePassword(mode: .login, flow: nil, route: route),
           by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
       )
    }
}

extension DeepLinkRouter {
    func handleDeepLinkRouting(for screen: Screen) -> Bool {
        if !appConfiguration.session.isValid {
            isInitializedFromDeeplink = shouldStartDeepLinkRoutingInInvalidSession(for: screen)
        } else {
            isInitializedFromDeeplink = shouldStartDeepLinkRoutingInValidSession(for: screen)
        }

        return isInitializedFromDeeplink
    }

    private func shouldStartDeepLinkRoutingInInvalidSession(for screen: Screen) -> Bool {
        if appConfiguration.session.hasAuthentication() {
            if appConfiguration.session.hasPassword() {
                return openLoginScreen(with: screen) != nil
            } else {
                router.launchMain()
//                rootViewController.setupTabBarController(withInitial: screen)
                return true
            }
        } else {
            router.launchOnboarding()
            return true
        }
    }

    private func shouldStartDeepLinkRoutingInValidSession(for screen: Screen) -> Bool {
        switch screen {
        case .addContact,
             .sendTransaction,
             .assetActionConfirmation:
//             .sendAssetTransactionPreview:
//            rootViewController.tabBarViewController.route = screen
//            rootViewController.tabBarViewController.routeForDeeplink()
            return true
        default:
            break
        }

        return false
    }
}

extension DeepLinkRouter {
    func openAsset(
        from notification: NotificationDetail,
        for account: String
    ) {
        
        
        if !appConfiguration.session.isValid {
            isInitializedFromDeeplink = true
            openAssetFromInvalidSesion(from: notification, for: account)
        } else {
            openAssetFromValidSesion(from: notification, for: account)
        }
    }

    private func openAssetFromInvalidSesion(from notification: NotificationDetail, for address: String) {
        if appConfiguration.session.hasAuthentication() {
            if appConfiguration.session.hasPassword() {
                openLoginScreen(with: getRoute(from: notification, for: address))
            } else {
                router.launchMain()
//                rootViewController.setupTabBarController(withInitial: getRoute(from: notification, for: address))
            }
        } else {
            router.launchOnboarding()
        }
    }
    
    private func openAssetFromValidSesion(from notification: NotificationDetail, for address: String) {
        guard let account = appConfiguration.sharedDataController.accountCollection[address]?.value else {
            return
        }

//        if let notificationtype = notification.notificationType,
//           let assetId = notification.asset?.id,
//           notificationtype == .assetSupportRequest {
//            openAssetSupportRequest(for: account, with: assetId)
//            return
//        } else {
//            openAssetDetail(for: account, with: getAssetDetail(from: notification, for: account))
//        }
    }

    private func getRoute(from notification: NotificationDetail, for address: String) -> Screen {
//        if let notificationtype = notification.notificationType,
//            notificationtype == .assetSupportRequest {
//            return .assetActionConfirmationNotification(address: address, assetId: notification.asset?.id)
//        } else {
//            return .assetDetailNotification(address: address, assetId: notification.asset?.id)
//        }
        return .passphraseVerify /// Fix build
    }

    private func openAssetSupportRequest(for account: Account, with assetId: Int64) {
        let draft = AssetAlertDraft(
            account: account,
            assetIndex: assetId,
            assetDetail: nil,
            title: "asset-support-add-title".localized,
            detail: String(format: "asset-support-add-message".localized, "\(account.name ?? "")"),
            actionTitle: "title-approve".localized,
            cancelTitle: "title-cancel".localized
        )

//        rootViewController.tabBarViewController.route = .assetActionConfirmation(assetAlertDraft: draft)
//        rootViewController.tabBarViewController.routeForDeeplink()
    }

    private func getAssetDetail(from notification: NotificationDetail, for account: Account) -> CompoundAsset? {
        return notification.asset?.id.unwrap { account[$0] }
    }

    private func openAssetDetail(for account: Account, with compoundAsset: CompoundAsset?) {
        rootViewController.tabBarContainer?.selectedIndex = 0

        guard let accountHandle = appConfiguration.sharedDataController.accountCollection[account.address] else {
            return
        }

        let screen: Screen
        if let compoundAsset = compoundAsset {
            screen = .assetDetail(draft: AssetTransactionListing(accountHandle: accountHandle, compoundAsset: compoundAsset))
        } else {
            screen = .algosDetail(draft: AlgoTransactionListing(accountHandle: accountHandle))
        }
//        rootViewController.tabBarViewController.route = screen
//        rootViewController.tabBarViewController.routeForDeeplink()
    }
}
