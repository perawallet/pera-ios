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
//  DeepLinkParser.swift

import UIKit

final class DeepLinkParser {
    private var url: URL!
    
    private let sharedDataController: SharedDataController
    
    init(
        sharedDataController: SharedDataController
    ) {
        self.sharedDataController = sharedDataController
    }

    var wcSessionRequestText: String? {
        let initialAlgorandPrefix = "algorand-wc://"

        if !url.absoluteString.hasPrefix(initialAlgorandPrefix) {
            return nil
        }

        let uriQueryKey = "uri"

        guard let possibleWCRequestText = url.queryParameters?[uriQueryKey] else {
            return nil
        }

        if possibleWCRequestText.isWalletConnectConnection {
            return possibleWCRequestText
        }

        return nil
    }
    
    var expectedScreen: Screen? {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let accountAddress = urlComponents.host,
            accountAddress.isValidatedAddress(),
            let qrText = url.buildQRText() else {
            return nil
        }
        
        switch qrText.mode {
        case .address:
//            return .addContact(address: accountAddress, name: qrText.label)
            return nil
        case .algosRequest:
            if let amount = qrText.amount {
                /// <todo> open send screen
                return nil
            }
        case .assetRequest:
            guard let assetId = qrText.asset,
                  let userAccounts = UIApplication.shared.appConfiguration?.sharedDataController.accountCollection.sorted() else {
                return nil
            }
            
            var requestedCompoundAsset: CompoundAsset?
            
            for account in userAccounts {
                for compoundAsset in account.value.compoundAssets where compoundAsset.id == assetId {
                    requestedCompoundAsset = compoundAsset
                }
            }
            
            guard let assetDetail = requestedCompoundAsset else {
                let assetAlertDraft = AssetAlertDraft(
                    account: nil,
                    assetIndex: assetId,
                    assetDetail: nil,
                    title: "asset-support-title".localized,
                    detail: "asset-support-error".localized,
                    actionTitle: "title-approve".localized,
                    cancelTitle: "title-cancel".localized
                )
                
//                return .assetActionConfirmation(draft: assetAlertDraft)
                return nil
            }
                
            if let amount = qrText.amount {
                /// <todo> open send screen
                return nil
            }
        case .mnemonic:
            return nil
        }
        
        return nil
    }
}

extension DeepLinkParser {
    func discover(
        _ notification: AlgorandNotification
    ) -> Result? {
        switch notification.detail?.type {
        case .transactionSent,
             .transactionReceived:
            return makeTransactionDetailScreen(from: notification)
        case .assetTransactionSent,
             .assetTransactionReceived,
             .assetSupportSuccess:
            return makeAssetTransactionDetailScreen(from: notification)
        case .assetSupportRequest:
            return makeAssetTransactionRequestScreen(from: notification)
        default:
            return nil
        }
    }
    
    private func makeTransactionDetailScreen(
        from notification: AlgorandNotification
    ) -> Result? {
        guard let accountAddress = notification.accountAddress else {
            return nil
        }
        
        guard
            let account = sharedDataController.accountCollection[accountAddress],
            account.isAvailable
        else {
            return .failure(.waitingForAccountToBeAvailable)
        }
        
        let draft = AlgoTransactionListing(accountHandle: account)
        return .success(.algosDetail(draft: draft))
    }
    
    private func makeAssetTransactionDetailScreen(
        from notification: AlgorandNotification
    ) -> Result? {
        guard
            let accountAddress = notification.accountAddress,
            let assetId = notification.detail?.asset?.id
        else {
            return nil
        }
        
        guard
            let account = sharedDataController.accountCollection[accountAddress],
            account.isAvailable
        else {
            return .failure(.waitingForAccountToBeAvailable)
        }
        
        guard let asset = account.value[assetId] else {
            return .failure(.waitingForAssetToBeAvailable)
        }
        
        let draft = AssetTransactionListing(accountHandle: account, compoundAsset: asset)
        return .success(.assetDetail(draft: draft))
    }
    
    private func makeAssetTransactionRequestScreen(
        from notification: AlgorandNotification
    ) -> Result? {
        guard
            let accountAddress = notification.accountAddress,
            let assetId = notification.detail?.asset?.id
        else {
            return nil
        }
        
        guard
            let account = sharedDataController.accountCollection[accountAddress],
            account.isAvailable
        else {
            return .failure(.waitingForAccountToBeAvailable)
        }
        
        let accountName = account.value.name.someString
        let draft = AssetAlertDraft(
            account: account.value,
            assetIndex: assetId,
            assetDetail: nil,
            title: "asset-support-add-title".localized,
            detail: String(format: "asset-support-add-message".localized, "\(accountName)"),
            actionTitle: "title-approve".localized,
            cancelTitle: "title-cancel".localized
        )
        return .success(.assetActionConfirmation(draft: draft))
    }
}

extension DeepLinkParser {
    typealias Result = Swift.Result<Screen, Error>
    
    enum Screen {
        case algosDetail(draft: TransactionListing)
        case assetDetail(draft: TransactionListing)
        case assetActionConfirmation(draft: AssetAlertDraft)
    }
    
    enum Error: Swift.Error {
        case waitingForAccountToBeAvailable
        case waitingForAssetToBeAvailable
    }
}
