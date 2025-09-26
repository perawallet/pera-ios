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
//  AppEndpoint.swift

import Foundation
import pera_wallet_core

/// Represents the new app-based deeplink endpoints
enum AppEndpoint: String, CaseIterable {
    case assetTransfer = "asset-transfer"
    case assetOptIn = "asset-opt-in"
    case keyReg = "keyreg"
    case addressAction = "address-action"
    case addContact = "add-contact"
    case editContact = "edit-contact"
    case addWatchAccount = "add-watch-account"
    case registerWatchAccount = "register-watch-account"
    case receiverAccountSelection = "receiver-account-selection"
    case addressActions = "address-actions"
    case recoverAddress = "recover-address"
    case walletConnect = "wallet-connect"
    case assetDetail = "asset-detail"
    case assetInbox = "asset-inbox"
    case discoverBrowser = "discover-browser"
    case discoverPath = "discover-path"
    case cardsPath = "cards-path"
    case stakingPath = "staking-path"
    case buy = "buy"
    case sell = "sell"
    case accountDetail = "account-detail"
    case webImport = "web-import"
    
    /// Parse QR text from app endpoint format
    func parseQRText(from url: URL) -> QRText? {
        let queryParams = url.queryParameters
        
        switch self {
        case .assetTransfer:
            return parseAssetTransferEndpoint(queryParams: queryParams)
        case .assetOptIn:
            return parseAssetOptInEndpoint(queryParams: queryParams)
        case .keyReg:
            return parseKeyRegEndpoint(queryParams: queryParams)
        case .addressAction:
            return parseAddressActionEndpoint(queryParams: queryParams)
        case .addContact:
            return parseAddContactEndpoint(queryParams: queryParams)
        case .editContact:
            return parseEditContactEndpoint(queryParams: queryParams)
        case .addWatchAccount, .registerWatchAccount:
            return parseAddWatchAccountEndpoint(queryParams: queryParams)
        case .receiverAccountSelection:
            return parseReceiverAccountSelectionEndpoint(queryParams: queryParams)
        case .addressActions:
            return parseAddressActionsEndpoint(queryParams: queryParams)
        case .recoverAddress:
            return parseRecoverAddressEndpoint(queryParams: queryParams)
        case .walletConnect:
            return parseWalletConnectEndpoint(queryParams: queryParams)
        case .assetDetail:
            return parseAssetDetailEndpoint(queryParams: queryParams)
        case .assetInbox:
            return parseAssetInboxEndpoint(queryParams: queryParams)
        case .discoverBrowser:
            return parseDiscoverBrowserEndpoint(queryParams: queryParams)
        case .discoverPath:
            return parseDiscoverPathEndpoint(queryParams: queryParams)
        case .cardsPath:
            return parseCardsPathEndpoint(queryParams: queryParams)
        case .stakingPath:
            return parseStakingPathEndpoint(queryParams: queryParams)
        case .buy:
            return parseBuyEndpoint(queryParams: queryParams)
        case .sell:
            return parseSellEndpoint(queryParams: queryParams)
        case .accountDetail:
            return parseAccountDetailEndpoint(queryParams: queryParams)
        case .webImport:
            return parseWebImportEndpoint(queryParams: queryParams)
        }
    }
    
    private func parseAssetTransferEndpoint(queryParams: [String: String]?) -> QRText? {
        guard let queryParams = queryParams else { return nil }
        
        let receiverAddress = queryParams["receiverAddress"]
        let amount = queryParams["amount"]
        let assetId = queryParams["assetId"]
        let note = queryParams["note"]
        let lockedNote = queryParams["xnote"]
        let label = queryParams["label"]
        
        // Determine if this is an ALGO transfer (assetId = 0) or asset transfer
        if let assetIdString = assetId,
           let assetIdValue = Int64(assetIdString) {
            
            if assetIdValue == 0 {
                // ALGO transfer
                return QRText(
                    mode: .algosRequest,
                    address: receiverAddress,
                    amount: amount.flatMap { UInt64($0) },
                    label: label,
                    note: note,
                    lockedNote: lockedNote
                )
            } else {
                // Asset transfer
                return QRText(
                    mode: .assetRequest,
                    address: receiverAddress,
                    amount: amount.flatMap { UInt64($0) },
                    label: label,
                    asset: assetIdValue,
                    note: note,
                    lockedNote: lockedNote
                )
            }
        }
        
        return nil
    }
    
    private func parseAssetOptInEndpoint(queryParams: [String: String]?) -> QRText? {
        guard let queryParams = queryParams,
              let assetIdString = queryParams["assetId"],
              let assetId = Int64(assetIdString) else {
            return nil
        }
        
        let address = queryParams["address"]
        
        return QRText(
            mode: .optInRequest,
            address: address,
            amount: 0,
            asset: assetId,
            note: queryParams["note"],
            lockedNote: queryParams["xnote"]
        )
    }
    
    private func parseKeyRegEndpoint(queryParams: [String: String]?) -> QRText? {
        guard let queryParams = queryParams,
              let address = queryParams["address"] else {
            return nil
        }
        
        let fee = queryParams["fee"]
        let voteKeyDilution = queryParams["votekd"]
        let voteFirst = queryParams["votefst"]
        let voteLast = queryParams["votelst"]
        
        let keyRegTransactionQRData = KeyRegTransactionQRData(
            fee: fee.flatMap { UInt64($0) },
            selectionKey: queryParams["selkey"],
            stateProofKey: queryParams["sprfkey"],
            voteKeyDilution: voteKeyDilution.flatMap { UInt64($0) },
            votingKey: queryParams["votekey"],
            voteFirst: voteFirst.flatMap { UInt64($0) },
            voteLast: voteLast.flatMap { UInt64($0) }
        )
        
        return QRText(
            mode: .keyregRequest,
            address: address,
            note: queryParams["note"],
            lockedNote: queryParams["xnote"],
            keyRegTransactionQRData: keyRegTransactionQRData,
            type: "keyreg"
        )
    }
    
    private func parseAddressActionEndpoint(queryParams: [String: String]?) -> QRText? {
        guard let queryParams = queryParams,
              let address = queryParams["address"] else {
            return nil
        }
        
        return QRText(
            mode: .address,
            address: address,
            label: queryParams["label"]
        )
    }
    
    private func parseAddContactEndpoint(queryParams: [String: String]?) -> QRText? {
        guard let queryParams = queryParams,
              let address = queryParams["address"] else {
            return nil
        }
        
        return QRText(
            mode: .addContact,
            address: address,
            label: queryParams["label"]
        )
    }
    
    private func parseEditContactEndpoint(queryParams: [String: String]?) -> QRText? {
        guard let queryParams = queryParams,
              let address = queryParams["address"] else {
            return nil
        }
        
        return QRText(
            mode: .editContact,
            address: address,
            label: queryParams["label"]
        )
    }
    
    private func parseAddWatchAccountEndpoint(queryParams: [String: String]?) -> QRText? {
        guard let queryParams = queryParams,
              let address = queryParams["address"] else {
            return nil
        }
        
        return QRText(
            mode: .addWatchAccount,
            address: address,
            label: queryParams["label"]
        )
    }
    
    private func parseReceiverAccountSelectionEndpoint(queryParams: [String: String]?) -> QRText? {
        guard let queryParams = queryParams,
              let address = queryParams["address"] else {
            return nil
        }
        
        return QRText(
            mode: .receiverAccountSelection,
            address: address,
            label: queryParams["label"]
        )
    }
    
    private func parseAddressActionsEndpoint(queryParams: [String: String]?) -> QRText? {
        guard let queryParams = queryParams,
              let address = queryParams["address"] else {
            return nil
        }
        
        return QRText(
            mode: .addressActions,
            address: address,
            label: queryParams["label"]
        )
    }
    
    private func parseRecoverAddressEndpoint(queryParams: [String: String]?) -> QRText? {
        guard let queryParams = queryParams,
              let mnemonic = queryParams["mnemonic"] else {
            return nil
        }
        
        return QRText(
            mode: .recoverAddress,
            mnemonic: mnemonic
        )
    }
    
    private func parseWalletConnectEndpoint(queryParams: [String: String]?) -> QRText? {
        guard let queryParams = queryParams,
              let walletConnectUrl = queryParams["walletConnectUrl"] ?? queryParams["uri"] else {
            return nil
        }
        
        return QRText(
            mode: .walletConnect,
            walletConnectUrl: walletConnectUrl
        )
    }
    
    private func parseAssetDetailEndpoint(queryParams: [String: String]?) -> QRText? {
        guard let queryParams = queryParams,
              let address = queryParams["address"],
              let assetIdString = queryParams["assetId"],
              let assetId = Int64(assetIdString) else {
            return nil
        }
        
        return QRText(
            mode: .assetDetail,
            address: address,
            asset: assetId
        )
    }
    
    private func parseAssetInboxEndpoint(queryParams: [String: String]?) -> QRText? {
        guard let queryParams = queryParams,
              let address = queryParams["address"] else {
            return nil
        }
        
        return QRText(
            mode: .assetInbox,
            address: address
        )
    }
    
    private func parseDiscoverBrowserEndpoint(queryParams: [String: String]?) -> QRText? {
        let url = queryParams?["url"]
        
        return QRText(
            mode: .discoverBrowser,
            url: url
        )
    }
    
    private func parseDiscoverPathEndpoint(queryParams: [String: String]?) -> QRText? {
        let path = queryParams?["path"]
        
        return QRText(
            mode: .discoverPath,
            path: path
        )
    }
    
    private func parseCardsPathEndpoint(queryParams: [String: String]?) -> QRText? {
        let path = queryParams?["path"]
        
        return QRText(
            mode: .cardsPath,
            path: path
        )
    }
    
    private func parseStakingPathEndpoint(queryParams: [String: String]?) -> QRText? {
        let path = queryParams?["path"]
        
        return QRText(
            mode: .stakingPath,
            path: path
        )
    }
    
    private func parseBuyEndpoint(queryParams: [String: String]?) -> QRText? {
        let address = queryParams?["address"]
        
        return QRText(
            mode: .buy,
            address: address
        )
    }
    
    private func parseSellEndpoint(queryParams: [String: String]?) -> QRText? {
        let address = queryParams?["address"]
        
        return QRText(
            mode: .sell,
            address: address
        )
    }
    
    private func parseAccountDetailEndpoint(queryParams: [String: String]?) -> QRText? {
        guard let queryParams = queryParams,
              let address = queryParams["address"] else {
            return nil
        }
        
        return QRText(
            mode: .accountDetail,
            address: address
        )
    }
    
    private func parseWebImportEndpoint(queryParams: [String: String]?) -> QRText? {
        guard let queryParams = queryParams,
              let backupId = queryParams["backupId"],
              let encryptionKey = queryParams["encryptionKey"] else {
            return nil
        }
        
        let action = queryParams["action"]
        
        return QRText(
            mode: .webImport,
            backupId: backupId,
            encryptionKey: encryptionKey,
            action: action
        )
    }
}

/// Helper for detecting and parsing app-based deeplinks
struct AppDeeplinkParser {
    static func isAppBasedDeeplink(_ url: URL) -> Bool {
        // For deeplinks: perawallet://app/...
        if url.host == "app" {
            return true
        }
        
        let pathComponents = url.pathComponents
        if pathComponents.contains("app") {
            return true
        }
        
        return false
    }
    
    static func parseEndpoint(from url: URL) -> AppEndpoint? {
        var endpointPath: String?
        
        if url.host == "app" {
            endpointPath = url.pathComponents.dropFirst().first
        }

        else {
            let pathComponents = url.pathComponents
            if let appIndex = pathComponents.firstIndex(of: "app"),
               appIndex + 1 < pathComponents.count {
                endpointPath = pathComponents[appIndex + 1]
            }
        }
        
        guard let path = endpointPath else { return nil }
        
        return AppEndpoint(rawValue: path)
    }
}
