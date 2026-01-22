// Copyright 2022-2025 Pera Wallet, LDA

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
//  DeepLinkParser.swift

import Foundation
import MacaroonUtils
import UIKit
import pera_wallet_core

final class DeepLinkParser {
    private let api: ALGAPI
    private let sharedDataController: SharedDataController
    private let peraConnect: PeraConnect
    
    init(
        api: ALGAPI,
        sharedDataController: SharedDataController,
        peraConnect: PeraConnect
    ) {
        self.api = api
        self.sharedDataController = sharedDataController
        self.peraConnect = peraConnect
    }
}

extension DeepLinkParser {
    func discover(
        notification: AlgorandNotification
    ) -> Result? {
        let action = resolveNotificationAction(for: notification)

        switch action {
        case .assetOptIn:
            return parseAssetTransactionRequest(from: notification)
        case .assetTransactions:
            return parseAssetTransactionDetail(from: notification)
        case .inAppBrowser, .url:
            return parseExternalBrowser(from: notification)
        default:
            return nil
        }
    }

    func resolveNotificationAction(
        for notification: AlgorandNotification
    ) -> NotificationAction? {
        guard let url = notification.detail?.url.toURL() else {
            return nil
        }

        return resolveNotificationAction(for: url)
    }

    func discover(
        notification: NotificationMessage
    ) -> Result? {
        
        let action = resolveNotificationAction(for: notification)

        switch action {
        case .assetOptIn:
            return parseAssetOptIn(from: notification)
        case .assetTransactions:
            return parseAssetTransactionDetail(from: notification)
        case .inAppBrowser, .url:
            return parseExternalBrowser(from: notification)
        case .assetInbox:
            return parseIncomingASA(from: notification)
        default:
            guard  let externalDeepLink = notification.url?.externalDeepLink else {
                return nil
            }
            return .success(.externalDeepLink(deepLink: externalDeepLink))
        }
    }

    private func resolveNotificationAction(
        for notificationMessage: NotificationMessage
    ) -> NotificationAction? {
        guard let url = notificationMessage.url else {
            return nil
        }

        return resolveNotificationAction(for: url)
    }

    private func resolveNotificationAction(
        for url: URL?
    ) -> NotificationAction? {
        guard let url = url else {
            return nil
        }

        if let host = url.host {
            let aRawValue = host + url.path
            return NotificationAction(rawValue: aRawValue)
        }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let actionName = queryItems.first?.name else {
            return nil
        }
        
        return NotificationAction(rawValue: actionName)
    }

    private func parseAssetOptIn(from notificationMessage: NotificationMessage) -> Result? {
        let url = notificationMessage.url
        let params = url?.queryParameters
        let accountAddress = params?["account"]
        let assetID = params?["asset"].unwrap { AssetID($0) }

        guard
            let accountAddress = accountAddress,
            let assetID = assetID
        else {
            return nil
        }

        guard sharedDataController.isAvailable else {
            return .failure(.waitingForAccountsToBeAvailable)
        }

        let account = sharedDataController.accountCollection[accountAddress]

        guard let account = account else {
            return .failure(.accountNotFound)
        }

        guard account.isAvailable else {
            return .failure(.waitingForAccountsToBeAvailable)
        }

        let rawAccount = account.value

        let isWatchAccount = rawAccount.authorization.isWatch

        if isWatchAccount {
            return .failure(.tryingToOptInForWatchAccount)
        }

        let isNoAuthAccount = rawAccount.authorization.isNoAuth
        if isNoAuthAccount {
            return .failure(.tryingToOptInForNoAuthInLocalAccount)
        }

        if rawAccount.containsAsset(assetID) {
            let asset = sharedDataController.assetDetailCollection[assetID]!
            return .success(.asaDiscoveryWithOptOutAction(account: rawAccount, asset: asset))
        }

        let monitor = sharedDataController.blockchainUpdatesMonitor
        let hasPendingOptInRequest = monitor.hasPendingOptInRequest(
            assetID: assetID,
            for: rawAccount
        )
        if hasPendingOptInRequest {
            let accountName = rawAccount.primaryDisplayName
            return .failure(.tryingToActForAssetWithPendingOptInRequest(accountName: accountName))
        }

        return .success(.asaDiscoveryWithOptInAction(account: rawAccount, assetID: assetID))
    }
    
    private func parseIncomingASA(from notificationMessage: NotificationMessage) -> Result? {
        let url = notificationMessage.url
        let params = url?.queryParameters
        let accountAddress = params?["account"]
        
        guard let accountAddress else {
            return .failure(.accountNotFound)
        }
        
        return .success(.assetInbox(
            address: accountAddress,
            requestsCount: 0
        ))
    }
    
    private func parseAssetTransactionDetail(from notificationMessage: NotificationMessage) -> Result? {
        let url = notificationMessage.url
        let params = url?.queryParameters
        let accountAddress = params?["account"]
        let transactionId = params?["transactionId"] as String?
        let assetID = params?["asset"].unwrap { AssetID($0) }

        guard
            let accountAddress = accountAddress,
            let assetID = assetID
        else {
            return nil
        }
        
        guard let transactionId else {
            if assetID == 0 {
                return makeTransactionASADetailScreen(accountAddress: accountAddress)
            } else {
                return makeAssetTransactionASADetailScreen(
                    accountAddress: accountAddress,
                    assetID: assetID
                )
            }
        }

        return makeTransactionDetailScreen(accountAddress: accountAddress, assetID: assetID, transactionId: transactionId)

    }

    private func parseAssetTransactionDetail(
        from notification: AlgorandNotification
    ) -> Result? {
        let url = notification.detail?.url.toURL()
        let params = url?.queryParameters
        let accountAddress = params?["account"]
        let transactionId = params?["transactionId"] as String?
        let assetID = params?["asset"].unwrap { AssetID($0) }

        guard
            let accountAddress = accountAddress,
            let assetID = assetID
        else {
            return nil
        }
        
        guard let transactionId else {
            if assetID == 0 {
                return makeTransactionASADetailScreen(accountAddress: accountAddress)
            } else {
                return makeAssetTransactionASADetailScreen(
                    accountAddress: accountAddress,
                    assetID: assetID
                )
            }
        }

        return makeTransactionDetailScreen(accountAddress: accountAddress, assetID: assetID, transactionId: transactionId)
    }
    
    private func parseAssetTransactionRequest(
        from notification: AlgorandNotification
    ) -> Result? {
        let url = notification.detail?.url.toURL()
        let params = url?.queryParameters
        let accountAddress = params?["account"]
        let assetID = params?["asset"].unwrap { AssetID($0) }

        guard
            let accountAddress = accountAddress,
            let assetID = assetID
        else {
            return nil
        }
        
        guard sharedDataController.isAvailable else {
            return .failure(.waitingForAccountsToBeAvailable)
        }

        let account = sharedDataController.accountCollection[accountAddress]

        guard let account = account else {
            return .failure(.accountNotFound)
        }

        guard account.isAvailable else {
            return .failure(.waitingForAccountsToBeAvailable)
        }

        let rawAccount = account.value

        let isWatchAccount = rawAccount.authorization.isWatch
        if isWatchAccount {
            return .failure(.tryingToOptInForWatchAccount)
        }

        let isNoAuthAccount = rawAccount.authorization.isNoAuth
        if isNoAuthAccount {
            return .failure(.tryingToOptInForNoAuthInLocalAccount)
        }

        if rawAccount.containsAsset(assetID) {
            let asset = sharedDataController.assetDetailCollection[assetID]!
            return .success(.asaDiscoveryWithOptOutAction(account: rawAccount, asset: asset))
        }

        let monitor = sharedDataController.blockchainUpdatesMonitor
        let hasPendingOptInRequest = monitor.hasPendingOptInRequest(
            assetID: assetID,
            for: rawAccount
        )
        if hasPendingOptInRequest {
            let accountName = rawAccount.primaryDisplayName
            return .failure(.tryingToActForAssetWithPendingOptInRequest(accountName: accountName))
        }
        
        let accountName = rawAccount.name ?? accountAddress
        let draft = AssetAlertDraft(
            account: rawAccount,
            assetId: assetID,
            asset: nil,
            title: String(localized: "asset-support-add-title"),
            detail: String(format: String(localized: "asset-support-add-message"), "\(accountName)"),
            actionTitle: String(localized: "title-approve"),
            cancelTitle: String(localized: "title-cancel")
        )
        return .success(.assetActionConfirmation(draft: draft))
    }

    private func parseExternalBrowser(from notificationMessage: NotificationMessage) -> Result? {
        let url = notificationMessage.url
        return makeExternalBrowserScreen(from: url)
    }

    private func parseExternalBrowser(from notification: AlgorandNotification) -> Result? {
        let url = notification.detail?.url.toURL()
        return makeExternalBrowserScreen(from: url)
    }
    
    private func makeTransactionASADetailScreen(
        for notification: AlgorandNotification
    ) -> Result? {
        let url = notification.detail?.url.toURL()
        let params = url?.queryParameters
        let accountAddress = params?["account"]

        guard let accountAddress = accountAddress else {
            return nil
        }
        
        return makeTransactionASADetailScreen(accountAddress: accountAddress)
    }

    private func makeTransactionASADetailScreen(
        accountAddress: PublicKey
    ) -> Result? {
        guard sharedDataController.isAvailable else {
            return .failure(.waitingForAccountsToBeAvailable)
        }

        let account = sharedDataController.accountCollection[accountAddress]

        guard let account = account else {
            return .failure(.accountNotFound)
        }

        guard account.isAvailable else {
            return .failure(.waitingForAccountsToBeAvailable)
        }

        let rawAccount = account.value
        return .success(.asaDetail(account: rawAccount, asset: rawAccount.algo))
    }
    
    private func makeTransactionDetailScreen(
        accountAddress: PublicKey,
        assetID: AssetID,
        transactionId: String
    ) -> Result? {
        guard sharedDataController.isAvailable else {
            return .failure(.waitingForAccountsToBeAvailable)
        }

        let account = sharedDataController.accountCollection[accountAddress]

        guard let account = account else {
            return .failure(.accountNotFound)
        }

        guard account.isAvailable else {
            return .failure(.waitingForAccountsToBeAvailable)
        }

        let rawAccount = account.value
        
        return .success(.transactionDetail(account: rawAccount, assetId: assetID, transactionId: transactionId))
        
    }

    private func makeAssetTransactionASADetailScreen(
        accountAddress: PublicKey,
        assetID: AssetID
    ) -> Result? {
        guard sharedDataController.isAvailable else {
            return .failure(.waitingForAccountsToBeAvailable)
        }

        let account = sharedDataController.accountCollection[accountAddress]

        guard let account = account else {
            return .failure(.accountNotFound)
        }

        guard account.isAvailable else {
            return .failure(.waitingForAccountsToBeAvailable)
        }

        let rawAccount = account.value

        let monitor = sharedDataController.blockchainUpdatesMonitor

        let hasPendingOptInRequest = monitor.hasPendingOptInRequest(
            assetID: assetID,
            for: rawAccount
        )
        if hasPendingOptInRequest {
            let accountName = rawAccount.primaryDisplayName
            return .failure(.tryingToActForAssetWithPendingOptInRequest(accountName: accountName))
        }

        let hasPendingOptOutRequest = monitor.hasPendingOptOutRequest(
            assetID: assetID,
            for: rawAccount
        )
        if hasPendingOptOutRequest {
            let accountName = rawAccount.primaryDisplayName
            return .failure(.tryingToActForAssetWithPendingOptOutRequest(accountName: accountName))
        }

        if let asset = rawAccount[assetID] as? StandardAsset {
            return .success(.asaDetail(account: rawAccount, asset: asset))
        }

        if let collectibleAsset = rawAccount[assetID] as? CollectibleAsset {
            return .success(.collectibleDetail(account: rawAccount, asset: collectibleAsset))
        }

        return .failure(.assetNotFound)
    }

    private func makeExternalBrowserScreen(from url: URL?) -> Result? {
        let params = url?.queryParameters
        guard let redirectedUrlString = params?["url"] else {
            return nil
        }

        guard let browserDeeplinkURL = url?.browserDeeplinkURL else {
            let redirectedURL = URL(string: redirectedUrlString)
            let redirectDestination = DiscoverExternalDestination.redirection(redirectedURL, api.network)
            return .success(.externalInAppBrowser(destination: redirectDestination))
        }
        
        let urlDestination = DiscoverExternalDestination.url(browserDeeplinkURL)
        return .success(.externalInAppBrowser(destination: urlDestination))
    }
}

extension DeepLinkParser {
    func discover(
        qrText: QRText
    ) -> Result? {
        switch qrText.mode {
        case .address:
            return makeActionSelectionScreen(
                qrText
            )
        case .algosRequest:
            return makeTransactionRequestScreen(
                qrText
            )
        case .assetRequest:
            return makeAssetTransactionRequestScreen(
                qrText
            )
        case .optInRequest:
            return makeAssetOptInRequestScreen(
                qrText
            )
        case .mnemonic:
            return nil
        case .keyregRequest:
            return makeKeyRegTransactionRequestScreen(
                qrText
            )
        case .buy:
            return makeBuyScreen(qrText)
        case .sell:
            return makeSellScreen(qrText)
        case .accountDetail:
            return makeAccountDetailScreen(qrText)
        case .addContact:
            return makeAddContactScreen(qrText)
        case .editContact:
            return makeEditContactScreen(qrText)
        case .addWatchAccount:
            return makeAddWatchAccountScreen(qrText)
        case .receiverAccountSelection:
            return makeReceiverAccountSelectionScreen(qrText)
        case .addressActions:
            return makeActionSelectionScreen(qrText)
        case .recoverAddress:
            return makeRecoverAddressScreen(qrText)
        case .assetDetail:
            return makeAssetDetailScreen(qrText)
        case .discoverBrowser:
            return makeDiscoverBrowserScreen(qrText)
        case .discoverPath:
            return makeDiscoverPathScreen(qrText)
        case .cardsPath:
            return makeCardsPathScreen(qrText)
        case .stakingPath:
            return makeStakingPathScreen(qrText)
        case .walletConnect:
            return nil
        case .assetInbox:
            return makeAssetInboxScreen(qrText)
        case .webImport:
            return makeWebImportScreen(qrText)
        case .swap:
            return makeSwapScreen(qrText)
        }
    }
    
    private func makeActionSelectionScreen(
        _ qr: QRText
    ) -> Result? {
        let address = qr.address
        return address.unwrap {
            .success(.actionSelection(address: $0, label: qr.label))
        }
    }
    
    private func makeTransactionRequestScreen(
        _ qr: QRText
    ) -> Result? {
        guard let amount = qr.amount else {
            return nil
        }

        guard
            let accountAddress = qr.address,
            sharedDataController.isAvailable
        else {
            return .failure(.waitingForAssetsToBeAvailable)
        }

        let qrDraft = QRSendTransactionDraft(
            toAccount: accountAddress,
            amount: amount.toAlgos,
            note: qr.note,
            lockedNote: qr.lockedNote,
            transactionMode: .algo
        )

        return .success(.sendTransaction(draft: qrDraft))
    }
    
    private func makeAssetTransactionRequestScreen(
        _ qr: QRText
    ) -> Result? {
        guard let assetId = qr.asset, let amount = qr.amount else {
            return nil
        }

        guard
            let accountAddress = qr.address,
            sharedDataController.isAvailable
        else {
            return .failure(.waitingForAssetsToBeAvailable)
        }

        let authorizedAccounts = sharedDataController.accountCollection.filter { $0.value.authorization.isAuthorized }

        let hasAsset = authorizedAccounts.contains { account in
            return account.value.containsAsset(assetId)
        }

        guard
            hasAsset,
            let assetDecoration = sharedDataController.assetDetailCollection[assetId]
        else {
            let draft = AssetAlertDraft(
                account: nil,
                assetId: assetId,
                asset: nil,
                title: String(localized: "asset-support-your-add-title"),
                detail: String(localized: "asset-support-your-add-message"),
                cancelTitle: String(localized: "title-close")
            )
            return .success(
                .assetActionConfirmation(
                    draft: draft,
                    theme: .secondaryActionOnly
                )
            )
        }

        /// <todo> Support the collectibles later when its detail screen is done.

        let qrDraft = QRSendTransactionDraft(
            toAccount: accountAddress,
            amount: amount.assetAmount(fromFraction: assetDecoration.decimals),
            note: qr.note,
            lockedNote: qr.lockedNote,
            transactionMode: .asset(StandardAsset(asset: ALGAsset(id: assetDecoration.id), decoration: assetDecoration))
        )

        let shouldFilterAccount: (Account) -> Bool = {
            !$0.containsAsset(assetId)
        }

        return .success(
            .sendTransaction(
                draft: qrDraft,
                shouldFilterAccount: shouldFilterAccount
            )
        )
    }

    private func makeAssetOptInRequestScreen(
        _ qr: QRText
    ) -> Result? {
        guard let assetID = qr.asset else {
            return nil
        }

        // If address is provided, validate and proceed with opt-in for specific account
        if let address = qr.address {
            guard sharedDataController.isAvailable else {
                return .failure(.waitingForAccountsToBeAvailable)
            }

            let account = sharedDataController.accountCollection[address]
            guard let account = account else {
                return .failure(.accountNotFound)
            }

            guard account.isAvailable else {
                return .failure(.waitingForAccountsToBeAvailable)
            }

            let rawAccount = account.value

            let isWatchAccount = rawAccount.authorization.isWatch
            if isWatchAccount {
                return .failure(.tryingToOptInForWatchAccount)
            }

            let isNoAuthAccount = rawAccount.authorization.isNoAuth
            if isNoAuthAccount {
                return .failure(.tryingToOptInForNoAuthInLocalAccount)
            }

            if rawAccount.containsAsset(assetID) {
                let asset = sharedDataController.assetDetailCollection[assetID]!
                return .success(.asaDiscoveryWithOptOutAction(account: rawAccount, asset: asset))
            }

            let monitor = sharedDataController.blockchainUpdatesMonitor
            let hasPendingOptInRequest = monitor.hasPendingOptInRequest(
                assetID: assetID,
                for: rawAccount
            )
            if hasPendingOptInRequest {
                let accountName = rawAccount.primaryDisplayName
                return .failure(.tryingToActForAssetWithPendingOptInRequest(accountName: accountName))
            }

            return .success(.asaDiscoveryWithOptInAction(account: rawAccount, assetID: assetID))
        }

        // If no address is provided, show account selection
        return .success(.accountSelect(asset: assetID))
    }
    
    private func makeKeyRegTransactionRequestScreen(
        _ qr: QRText
    ) -> Result? {
        guard
            let accountAddress = qr.address,
            sharedDataController.isAvailable
        else {
            return .failure(.waitingForAssetsToBeAvailable)
        }
        
        guard let account = sharedDataController.accountCollection[accountAddress]?.value else {
            return .failure(.accountNotFound)
        }

        let draft = KeyRegTransactionSendDraft(
            account: account,
            qrText: qr
        )

        return .success(.keyRegTransaction(account: account, draft: draft))
    }
    
    private func makeBuyScreen(_ qr: QRText) -> Result? {
        if let address = qr.address {
            return .success(.buy(address: address))
        } else {
            return .success(.buyAccountSelection)
        }
    }
    
    private func makeSellScreen(_ qr: QRText) -> Result? {
        if let address = qr.address {
            return .success(.sell(address: address))
        } else {
            return .success(.sellAccountSelection)
        }
    }
    
    private func makeAccountDetailScreen(_ qr: QRText) -> Result? {
        guard let address = qr.address else {
            return nil
        }
        
        return .success(.accountDetail(address: address))
    }
    
    private func makeAssetDetailScreen(_ qr: QRText) -> Result? {
        guard let address = qr.address,
              let assetId = qr.asset,
              sharedDataController.isAvailable else {
            return .failure(.waitingForAccountsToBeAvailable)
        }
        
        let account = sharedDataController.accountCollection[address]
        guard let account = account else {
            return .failure(.accountNotFound)
        }
        
        guard account.isAvailable else {
            return .failure(.waitingForAccountsToBeAvailable)
        }
        
        let rawAccount = account.value
        
        if let asset = rawAccount[assetId] as? StandardAsset {
            return .success(.asaDetail(account: rawAccount, asset: asset))
        }
        
        if let collectibleAsset = rawAccount[assetId] as? CollectibleAsset {
            return .success(.collectibleDetail(account: rawAccount, asset: collectibleAsset))
        }
        
        return .failure(.assetNotFound)
    }
    
    private func makeDiscoverBrowserScreen(_ qr: QRText) -> Result? {
        guard let url = qr.url, !url.isEmpty else {
            let externalDeepLink = ExternalDeepLink.discover(path: "main/browser")
            return .success(.externalDeepLink(deepLink: externalDeepLink))
        }
        
        guard let browserURL = URL(string: url) else {
            let externalDeepLink = ExternalDeepLink.discover(path: "main/browser")
            return .success(.externalDeepLink(deepLink: externalDeepLink))
        }
        
        let destination = DiscoverExternalDestination.url(browserURL)
        return .success(.externalInAppBrowser(destination: destination))
    }
    
    private func makeDiscoverPathScreen(_ qr: QRText) -> Result? {
        let path = qr.path
        let externalDeepLink = ExternalDeepLink.discover(path: path)
        return .success(.externalDeepLink(deepLink: externalDeepLink))
    }
    
    private func makeCardsPathScreen(_ qr: QRText) -> Result? {
        let path = qr.path
        let externalDeepLink = ExternalDeepLink.cards(path: path)
        return .success(.externalDeepLink(deepLink: externalDeepLink))
    }
    
    private func makeStakingPathScreen(_ qr: QRText) -> Result? {
        let path = qr.path
        let externalDeepLink = ExternalDeepLink.staking(path: path)
        return .success(.externalDeepLink(deepLink: externalDeepLink))
    }
    
    private func makeSwapScreen(_ qr: QRText) -> Result? {
        return .success(.swap(address: qr.address, asssetInId: qr.assetInId, assetOutId: qr.assetOutId))
    }
    
    private func makeWebImportScreen(_ qr: QRText) -> Result? {
        guard let backupId = qr.backupId,
              let encryptionKey = qr.encryptionKey else {
            return nil
        }
        
        let qrBackupParameters = QRBackupParameters(
            id: backupId,
            encryptionKey: encryptionKey,
            action: qr.action ?? "import"
        )
        
        return .success(.webImport(parameters: qrBackupParameters))
    }
    
    private func makeRecoverAddressScreen(_ qr: QRText) -> Result? {
        guard let mnemonic = qr.mnemonic else {
            return nil
        }
        
        let words = mnemonic.components(separatedBy: CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: ",")))
            .compactMap { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : $0 }
        
        let walletType: WalletFlowType = words.count == 25 ? .algo25 : .bip39
        
        return .success(.recoverAddress(mnemonic: mnemonic, walletType: walletType))
    }
    
    private func makeAssetInboxScreen(_ qr: QRText) -> Result? {
        guard let address = qr.address else {
            return nil
        }
        
        return .success(.assetInbox(
            address: address,
            requestsCount: 0
        ))
    }
    
    private func makeAddContactScreen(_ qr: QRText) -> Result? {
        guard let address = qr.address else {
            return nil
        }
        
        return .success(.addContact(address: address, label: qr.label))
    }
    
    private func makeEditContactScreen(_ qr: QRText) -> Result? {
        guard let address = qr.address else {
            return nil
        }
        
        return .success(.editContact(address: address, label: qr.label))
    }
    
    private func makeAddWatchAccountScreen(_ qr: QRText) -> Result? {
        guard let address = qr.address else {
            return nil
        }
        
        return .success(.addWatchAccount(address: address, label: qr.label))
    }
    
    private func makeReceiverAccountSelectionScreen(_ qr: QRText) -> Result? {
        guard let address = qr.address else {
            return nil
        }
        
        return .success(.receiverAccountSelection(address: address))
    }
}

extension DeepLinkParser {
    func discover(
        walletConnectSessionRequest: URL
    ) -> Swift.Result<WalletConnectSessionRequestResponse, Error>? {
        if !sharedDataController.isAvailable {
            return .failure(.waitingForAccountsToBeAvailable)
        }
        
        let urlComponents =
            URLComponents(url: walletConnectSessionRequest, resolvingAgainstBaseURL: true)
        let queryItems = urlComponents?.queryItems
        
        let maybeWalletConnectSessionKey: String
        if let key = queryItems?.first(matching: (\.name, "uri"))?.value.unwrap(or: "") {
            maybeWalletConnectSessionKey = key
        } else if let urlString = urlComponents?.url?.absoluteString, urlString.containsCaseInsensitive("wc:") {
            maybeWalletConnectSessionKey = urlString
        } else {
            return nil
        }
        
        let isAccountMultiselectionEnabled = queryItems?.first(where: { $0.name == Constants.Cards.singleAccount.rawValue })?.value == "true"
        let mandotaryAccount = queryItems?.first(where: { $0.name == Constants.Cards.selectedAccount.rawValue })?.value
        let result = WalletConnectSessionRequestResponse(
            walletConnectSessionKey: maybeWalletConnectSessionKey,
            isAccountMultiselectionEnabled: !isAccountMultiselectionEnabled,
            mandotaryAccount: mandotaryAccount
        )
        
        return
            peraConnect.isValidSession(maybeWalletConnectSessionKey) ?
            .success(result) :
            nil
    }
    
    func discover(
        walletConnectTransactionSignRequest draft: WalletConnectTransactionSignRequestDraft
    ) -> Result? {
        if !sharedDataController.isAvailable {
            return .failure(.waitingForAccountsToBeAvailable)
        }
        
        return .success(.wcMainTransactionScreen(draft: draft))
    }

    func discover(
        walletConnectArbitraryDataSignRequest draft: WalletConnectArbitraryDataSignRequestDraft
    ) -> Result? {
        if !sharedDataController.isAvailable {
            return .failure(.waitingForAccountsToBeAvailable)
        }

        return .success(.wcMainArbitraryDataScreen(draft: draft))
    }

    func discoverBuyAlgoWithMeld(
        draft: MeldDraft
    ) -> Result? {
        if !sharedDataController.isAvailable {
            return .failure(.waitingForAccountsToBeAvailable)
        }

        return .success(.buyAlgoWithMeld(draft))
    }
}

extension DeepLinkParser {
    typealias Result = Swift.Result<Screen, Error>
    
    enum Screen {
        case actionSelection(
            address: String,
            label: String?
        )
        case assetActionConfirmation(
            draft: AssetAlertDraft,
            theme: AssetActionConfirmationViewControllerTheme = .init()
        )
        case asaDiscoveryWithOptInAction(
            account: Account,
            assetID: AssetID
        )
        case asaDiscoveryWithOptOutAction(
            account: Account,
            asset: AssetDecoration
        )
        case asaDetail(
            account: Account,
            asset: Asset
        )
        case collectibleDetail(
            account: Account,
            asset: CollectibleAsset
        )
        case sendTransaction(
            draft: QRSendTransactionDraft,
            shouldFilterAccount: ((Account) -> Bool)? = nil
        )
        case transactionDetail(
            account: Account,
            assetId: AssetID,
            transactionId: String
        )
        case keyRegTransaction(account: Account, draft: KeyRegTransactionSendDraft)
        case wcMainTransactionScreen(draft: WalletConnectTransactionSignRequestDraft)
        case wcMainArbitraryDataScreen(draft: WalletConnectArbitraryDataSignRequestDraft)
        case accountSelect(asset: AssetID)
        case externalInAppBrowser(destination: DiscoverExternalDestination)
        case externalDeepLink(deepLink: ExternalDeepLink)
        case buyAlgoWithMeld(MeldDraft)
        case assetInbox(
            address: String,
            requestsCount: Int
        )
        case qrScanner
        case buy(address: String)
        case buyAccountSelection
        case sell(address: String)
        case sellAccountSelection
        case accountDetail(address: String)
        case webImport(parameters: QRBackupParameters)
        case recoverAddress(mnemonic: String, walletType: WalletFlowType)
        case addContact(address: String, label: String?)
        case editContact(address: String, label: String?)
        case addWatchAccount(address: String, label: String?)
        case receiverAccountSelection(address: String)
        case swap(address: String?, asssetInId: AssetID?, assetOutId: AssetID?)
    }
    
    enum Error:
        Swift.Error,
        Equatable {
        case waitingForAccountsToBeAvailable
        case waitingForAssetsToBeAvailable
        case tryingToOptInForWatchAccount
        case tryingToOptInForNoAuthInLocalAccount
        case tryingToActForAssetWithPendingOptInRequest(accountName: String)
        case tryingToActForAssetWithPendingOptOutRequest(accountName: String)
        case accountNotFound
        case assetNotFound
        case transactionNotFound

        typealias UIRepresentation = (title: String, description: String)

        var uiRepresentation: UIRepresentation {
            let title: String
            let description: String

            switch self {
            case .tryingToOptInForWatchAccount:
                title = String(localized: "notifications-trying-to-opt-in-for-watch-account-title")
                description = String(localized: "notifications-trying-to-opt-in-for-watch-account-description")
            case .tryingToOptInForNoAuthInLocalAccount: 
                title = String(localized: "notifications-trying-to-opt-in-for-watch-account-title")
                description = String(localized: "action-not-available-for-account-type")
            case .tryingToActForAssetWithPendingOptInRequest(let accountName):
                title = String(localized: "title-error")
                description = String(format: String(localized: "ongoing-opt-in-request-description"), accountName)
            case .tryingToActForAssetWithPendingOptOutRequest(let accountName):
                title = String(localized: "title-error")
                description = String(format: String(localized: "ongoing-opt-out-request-description"), accountName)
            case .accountNotFound:
                title = String(localized: "notifications-account-not-found-title")
                description = String(localized: "notifications-account-not-found-description")
            case .assetNotFound:
                title = String(localized: "notifications-asset-not-found-title")
                description = String(localized: "notifications-asset-not-found-description")
            default:
                preconditionFailure("Error mapping must be done properly.")
            }

            return UIRepresentation(
                title: title,
                description: description
            )
        }

        static func == (
            lhs: Self,
            rhs: Self
        ) -> Bool {
            switch (lhs, rhs) {
            case (.waitingForAccountsToBeAvailable, .waitingForAccountsToBeAvailable):
                return true
            case (.waitingForAssetsToBeAvailable, .waitingForAssetsToBeAvailable):
                return true
            case (.tryingToOptInForWatchAccount, .tryingToOptInForWatchAccount):
                return true
            case (.tryingToOptInForNoAuthInLocalAccount, .tryingToOptInForNoAuthInLocalAccount):
                return true
            case (.tryingToActForAssetWithPendingOptInRequest(let accountName1), .tryingToActForAssetWithPendingOptInRequest(let accountName2)):
                return accountName1 == accountName2
            case (.tryingToActForAssetWithPendingOptOutRequest(let accountName1), .tryingToActForAssetWithPendingOptOutRequest(let accountName2)):
                return accountName1 == accountName2
            case (.accountNotFound, .accountNotFound):
                return true
            case (.assetNotFound, .assetNotFound):
                return true
            default:
                return false
            }
        }
    }
}

extension DeepLinkParser {
    enum NotificationAction: String {
        case assetOptIn = "asset/opt-in"
        case assetTransactions = "asset/transactions"
        case inAppBrowser = "in-app-browser"
        case url = "url"
        case assetInbox = "asset-inbox"
    }
}
