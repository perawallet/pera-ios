//
//  DeepLinkRouter.swift

import UIKit

class DeepLinkRouter: NSObject {

    private weak var rootViewController: RootViewController?
    private let appConfiguration: AppConfiguration

    init(rootViewController: RootViewController?, appConfiguration: AppConfiguration) {
        self.rootViewController = rootViewController
        self.appConfiguration = appConfiguration
        super.init()
    }

    @discardableResult
    private func openLoginScreen(with route: Screen? = nil) -> UIViewController? {
        return rootViewController?.open(
           .choosePassword(mode: .login, flow: nil, route: route),
           by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
       )
    }
}

extension DeepLinkRouter {
    func handleDeepLinkRouting(for screen: Screen) -> Bool {
        if !appConfiguration.session.isValid {
            return shouldStartDeepLinkRoutingInInvalidSession(for: screen)
        } else {
            return shouldStartDeepLinkRoutingInValidSession(for: screen)
        }
    }

    private func shouldStartDeepLinkRoutingInInvalidSession(for screen: Screen) -> Bool {
        if appConfiguration.session.hasPassword() && appConfiguration.session.authenticatedUser != nil {
            return openLoginScreen(with: screen) != nil
        } else {
            return rootViewController?.open(.introduction(flow: .initializeAccount(mode: nil)), by: .launch, animated: false) != nil
        }
    }

    private func shouldStartDeepLinkRoutingInValidSession(for screen: Screen) -> Bool {
        switch screen {
        case .addContact,
             .sendAlgosTransactionPreview,
             .assetSupport,
             .sendAssetTransactionPreview:
            rootViewController?.tabBarViewController.route = screen
            rootViewController?.tabBarViewController.routeForDeeplink()
            return true
        default:
            break
        }

        return false
    }
}

extension DeepLinkRouter {
    func openAsset(from notification: NotificationDetail, for account: String) {
        if !appConfiguration.session.isValid {
            openAssetFromInvalidSesion(from: notification, for: account)
        } else {
            openAssetFromValidSesion(from: notification, for: account)
        }
    }

    private func openAssetFromInvalidSesion(from notification: NotificationDetail, for address: String) {
        if appConfiguration.session.hasPassword() && appConfiguration.session.authenticatedUser != nil {
            if let notificationtype = notification.notificationType,
                notificationtype == .assetSupportRequest {
                openLoginScreen(with: .assetActionConfirmationNotification(address: address, assetId: notification.asset?.id))
                return
            } else {
                openLoginScreen(with: .assetDetailNotification(address: address, assetId: notification.asset?.id))
            }
        } else {
            rootViewController?.open(.introduction(flow: .initializeAccount(mode: nil)), by: .launch, animated: false)
        }
    }

    private func openAssetFromValidSesion(from notification: NotificationDetail, for address: String) {
        guard let account = appConfiguration.session.account(from: address) else {
            return
        }

        if let notificationtype = notification.notificationType,
           let assetId = notification.asset?.id,
           notificationtype == .assetSupportRequest {
            openAssetSupportRequest(for: account, with: assetId)
            return
        } else {
            openAssetDetail(for: account, with: getAssetDetail(from: notification, for: account))
        }
    }

    private func openAssetSupportRequest(for account: Account, with assetId: Int64) {
        let draft = AssetAlertDraft(
            account: account,
            assetIndex: assetId,
            assetDetail: nil,
            title: "asset-support-add-title".localized,
            detail: String(format: "asset-support-add-message".localized, "\(account.name ?? "")"),
            actionTitle: "title-ok".localized
        )

        rootViewController?.tabBarViewController.route = .assetActionConfirmation(assetAlertDraft: draft)
        rootViewController?.tabBarViewController.routeForDeeplink()
    }

    private func getAssetDetail(from notification: NotificationDetail, for account: Account) -> AssetDetail? {
        var assetDetail: AssetDetail?

        if let assetId = notification.asset?.id {
            assetDetail = account.assetDetails.first { $0.id == assetId }
        }

        return assetDetail
    }

    private func openAssetDetail(for account: Account, with assetDetail: AssetDetail?) {
        rootViewController?.tabBarContainer?.selectedItem = rootViewController?.tabBarContainer?.items[0]
        rootViewController?.tabBarViewController.route = .assetDetail(account: account, assetDetail: assetDetail)
        rootViewController?.tabBarViewController.routeForDeeplink()
    }
}
