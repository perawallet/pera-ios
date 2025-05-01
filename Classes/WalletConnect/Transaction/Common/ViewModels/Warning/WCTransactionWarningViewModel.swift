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
//   WCTransactionWarningViewModel.swift

import UIKit

class WCTransactionWarningViewModel {
    private(set) var title: String?

    init(warning: WCTransactionWarning) {
        setTitle(from: warning)
    }

    private func setTitle(from warning: WCTransactionWarning) {
        switch warning {
        case .rekeyed:
            title = String(localized: "wallet-connect-transaction-warning-rekey")
        case .closeAlgos:
            title = String(localized: "wallet-connect-transaction-warning-close-algos")
        case let .closeAsset(asset):
            let assetDisplayName = asset.naming.displayNames.primaryName
            title = String(format: String(localized: "wallet-connect-transaction-warning-close-asset"), assetDisplayName, assetDisplayName)
        case .fee:
            title = String(localized: "wallet-connect-transaction-warning-high-fee")
        case .assetDelete:
            title = String(localized: "wallet-connect-asset-deletion-warning-title")
        }
    }
}

enum WCTransactionWarning {
    case rekeyed
    case closeAlgos
    case closeAsset(asset: Asset)
    case fee
    case assetDelete
}
