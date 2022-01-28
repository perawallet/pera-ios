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

struct DeepLinkParser {
    
    private let url: URL
    
    init(url: URL) {
        self.url = url
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
            return .addContact(address: accountAddress, name: qrText.label)
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
                
                return .assetActionConfirmation(assetAlertDraft: assetAlertDraft)
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
