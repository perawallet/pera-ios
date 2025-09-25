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
//  QRText.swift

import Foundation

public final class QRText: Codable {
    public let mode: QRMode
    public let version = "1.0"
    public let address: String?
    public var mnemonic: String?
    public var amount: UInt64?
    public var label: String?
    public var asset: Int64?
    public var note: String?
    public var lockedNote: String?
    public let type: String?
    public var keyRegTransactionQRData: KeyRegTransactionQRData?
    public var walletConnectUrl: String?
    public var url: String?
    public var path: String?
    
    public init(
        mode: QRMode,
        address: String? = nil,
        mnemonic: String? = nil,
        amount: UInt64? = nil,
        label: String? = nil,
        asset: Int64? = nil,
        note: String? = nil,
        lockedNote: String? = nil,
        keyRegTransactionQRData: KeyRegTransactionQRData? = nil,
        type: String? = nil,
        walletConnectUrl: String? = nil,
        url: String? = nil,
        path: String? = nil
    ) {
        self.mode = mode
        self.address = address
        self.mnemonic = mnemonic
        self.amount = amount
        self.label = label
        self.asset = asset
        self.note = note
        self.lockedNote = lockedNote
        self.keyRegTransactionQRData = keyRegTransactionQRData
        self.type = type
        self.walletConnectUrl = walletConnectUrl
        self.url = url
        self.path = path
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        address = try values.decodeIfPresent(String.self, forKey: .address)
        label = try values.decodeIfPresent(String.self, forKey: .label)
        mnemonic = try values.decodeIfPresent(String.self, forKey: .mnemonic)
        
        if let amountText = try values.decodeIfPresent(String.self, forKey: .amount) {
            amount = UInt64(amountText)
        }
        
        if let assetText = try values.decodeIfPresent(String.self, forKey: .asset) {
            asset = Int64(assetText)
        }

        note = try values.decodeIfPresent(String.self, forKey: .note)
        lockedNote = try values.decodeIfPresent(String.self, forKey: .lockedNote)
        type = try values.decodeIfPresent(String.self, forKey: .type)

        if mnemonic != nil {
            mode = .mnemonic
        } else if asset != nil,
                  amount != nil {
            if amount == 0 && address == nil {
                mode = .optInRequest
            } else {
                mode = .assetRequest
            }
        } else if try values.decodeIfPresent(String.self, forKey: .amount) != nil {
            mode = .algosRequest
        } else if type == "keyreg" {
            mode = .keyregRequest
        } else {
            mode = .address
        }
        
        if mode == .keyregRequest {
            let fee: UInt64? = try values.decodeIfPresent(UInt64.self, forKey: .fee)
            let selectionKey: String? = try values.decodeIfPresent(String.self, forKey: .selectionKey)
            let stateProofKey: String? = try values.decodeIfPresent(String.self, forKey: .stateProofKey)
            let voteKeyDilution: UInt64? = try values.decodeIfPresent(UInt64.self, forKey: .voteKeyDilution)
            let votingKey: String? = try values.decodeIfPresent(String.self, forKey: .votingKey)
            let voteFirst: UInt64? = try values.decodeIfPresent(UInt64.self, forKey: .voteFirst)
            let voteLast: UInt64? = try values.decodeIfPresent(UInt64.self, forKey: .voteLast)

            keyRegTransactionQRData = KeyRegTransactionQRData(
                fee: fee,
                selectionKey: selectionKey,
                stateProofKey: stateProofKey,
                voteKeyDilution: voteKeyDilution,
                votingKey: votingKey,
                voteFirst: voteFirst,
                voteLast: voteLast
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(version, forKey: .version)
        
        switch mode {
        case .mnemonic:
            try container.encode(mnemonic, forKey: .mnemonic)
        case .address:
            if let address = address {
                try container.encode(address, forKey: .address)
            }
            if let label = label {
                try container.encode(label, forKey: .label)
            }
        case .algosRequest:
            if let address = address {
                try container.encode(address, forKey: .address)
            }
            if let amount = amount {
                try container.encode(amount, forKey: .amount)
            }
            if let note = note {
                try container.encode(note, forKey: .note)
            }
            if let lockedNote = lockedNote {
                try container.encode(lockedNote, forKey: .lockedNote)
            }
        case .assetRequest:
            if let address = address {
                try container.encode(address, forKey: .address)
            }
            if let amount = amount {
                try container.encode(amount, forKey: .amount)
            }
            if let asset = asset {
                try container.encode(asset, forKey: .asset)
            }
            if let note = note {
                try container.encode(note, forKey: .note)
            }
            if let lockedNote = lockedNote {
                try container.encode(lockedNote, forKey: .lockedNote)
            }
        case .optInRequest:
            if let amount = amount {
                try container.encode(amount, forKey: .amount)
            }
            if let asset = asset {
                try container.encode(asset, forKey: .asset)
            }
        case .keyregRequest:
            if let fee = keyRegTransactionQRData?.fee {
                try container.encode(fee, forKey: .fee)
            }
            if let selectionKey = keyRegTransactionQRData?.selectionKey {
                try container.encode(selectionKey, forKey: .selectionKey)
            }
            if let stateProofKey = keyRegTransactionQRData?.stateProofKey {
                try container.encode(stateProofKey, forKey: .stateProofKey)
            }
            if let voteKeyDilution = keyRegTransactionQRData?.voteKeyDilution {
                try container.encode(voteKeyDilution, forKey: .voteKeyDilution)
            }
            if let votingKey = keyRegTransactionQRData?.votingKey {
                try container.encode(votingKey, forKey: .votingKey)
            }
            if let voteFirst = keyRegTransactionQRData?.voteFirst {
                try container.encode(voteFirst, forKey: .voteFirst)
            }
            if let voteLast = keyRegTransactionQRData?.voteLast {
                try container.encode(voteLast, forKey: .voteLast)
            }
        case .addContact, .editContact, .addWatchAccount, .receiverAccountSelection, .addressActions, .buy, .sell, .accountDetail:
            if let address = address {
                try container.encode(address, forKey: .address)
            }
            if let label = label {
                try container.encode(label, forKey: .label)
            }
        case .recoverAddress:
            if let mnemonic = mnemonic {
                try container.encode(mnemonic, forKey: .mnemonic)
            }
        case .walletConnect:
            if let walletConnectUrl = walletConnectUrl {
                try container.encode(walletConnectUrl, forKey: .walletConnectUrl)
            }
        case .assetDetail, .assetInbox:
            if let address = address {
                try container.encode(address, forKey: .address)
            }
            if let asset = asset {
                try container.encode(asset, forKey: .asset)
            }
        case .discoverBrowser:
            if let url = url {
                try container.encode(url, forKey: .url)
            }
        case .discoverPath, .cardsPath, .stakingPath:
            if let path = path {
                try container.encode(path, forKey: .path)
            }
        }
    }

    public class func build(for address: String?, with queryParameters: [String: String]?) -> Self? {
        guard let queryParameters = queryParameters else {
            if let address = address {
                return Self(mode: .address, address: address)
            }

            return nil
        }
        
        if let type = queryParameters[QRText.CodingKeys.type.rawValue],
           type == "keyreg" {
            let fee = queryParameters[KeyRegTransactionQRData.CodingKeys.fee.rawValue]
            let voteKeyDilution = queryParameters[KeyRegTransactionQRData.CodingKeys.voteKeyDilution.rawValue]
            let voteFirst = queryParameters[KeyRegTransactionQRData.CodingKeys.voteFirst.rawValue]
            let voteLast = queryParameters[KeyRegTransactionQRData.CodingKeys.voteLast.rawValue]
            
            let keyRegTransactionQRData = KeyRegTransactionQRData(
                fee: fee != nil ? UInt64(fee!) : nil,
                selectionKey: queryParameters[KeyRegTransactionQRData.CodingKeys.selectionKey.rawValue],
                stateProofKey: queryParameters[KeyRegTransactionQRData.CodingKeys.stateProofKey.rawValue],
                voteKeyDilution: voteKeyDilution != nil ? UInt64(voteKeyDilution!) : nil,
                votingKey: queryParameters[KeyRegTransactionQRData.CodingKeys.votingKey.rawValue],
                voteFirst: voteFirst != nil ? UInt64(voteFirst!) : nil,
                voteLast: voteLast != nil ? UInt64(voteLast!) : nil
            )
            return Self(
                mode: .keyregRequest,
                address: address,
                note: queryParameters[QRText.CodingKeys.note.rawValue],
                lockedNote: queryParameters[QRText.CodingKeys.lockedNote.rawValue],
                keyRegTransactionQRData: keyRegTransactionQRData
                    
            )
        }
        
        // Handle new type parameters
        if let type = queryParameters[QRText.CodingKeys.type.rawValue] {
            if type == "asset/opt-in", let assetIdString = queryParameters[QRText.CodingKeys.asset.rawValue] {
                return Self(
                    mode: .optInRequest,
                    address: address,
                    amount: 0,
                    asset: Int64(assetIdString),
                    note: queryParameters[QRText.CodingKeys.note.rawValue],
                    lockedNote: queryParameters[QRText.CodingKeys.lockedNote.rawValue]
                )
            }
            
            if type == "asset/transactions", let assetIdString = queryParameters[QRText.CodingKeys.asset.rawValue] {
                return Self(
                    mode: .assetDetail,
                    address: address,
                    asset: Int64(assetIdString)
                )
            }
            
            if type == "asset-inbox" {
                return Self(
                    mode: .assetInbox,
                    address: address
                )
            }
        }
        
        // Handle URL parameter for browser discovery
        if let url = queryParameters["url"] {
            return Self(
                mode: .discoverBrowser,
                url: url
            )
        }

        if let amount = queryParameters[QRText.CodingKeys.amount.rawValue],
           let asset = queryParameters[QRText.CodingKeys.asset.rawValue] {

            if let address = address {
                return Self(
                    mode: .assetRequest,
                    address: address,
                    amount: UInt64(amount),
                    asset: Int64(asset),
                    note: queryParameters[QRText.CodingKeys.note.rawValue],
                    lockedNote: queryParameters[QRText.CodingKeys.lockedNote.rawValue]
                )
            }

            if amount == "0" {
                return Self(
                    mode: .optInRequest,
                    address: nil,
                    amount: UInt64(amount),
                    asset: Int64(asset),
                    note: queryParameters[QRText.CodingKeys.note.rawValue],
                    lockedNote: queryParameters[QRText.CodingKeys.lockedNote.rawValue]
                )
            }

            return nil
        }

        guard let address = address else {
            return nil
        }

        if let amount = queryParameters[QRText.CodingKeys.amount.rawValue] {
            return Self(
                mode: .algosRequest,
                address: address,
                amount: UInt64(amount),
                note: queryParameters[QRText.CodingKeys.note.rawValue],
                lockedNote: queryParameters[QRText.CodingKeys.lockedNote.rawValue]
            )
        }

        if let label = queryParameters[QRText.CodingKeys.label.rawValue] {
            return Self(mode: .address, address: address, label: label)
        }

        return nil
    }
}

extension QRText {
    /// Generate QR text using the legacy format (backward compatibility)
    public func qrText() -> String {
        return qrTextLegacyFormat()
    }
    
    /// Generate QR text using the new app-based format
    public func qrTextAppFormat() -> String {
        let deeplinkConfig = ALGAppTarget.current.deeplinkConfig.qr
        let base = "\(deeplinkConfig.preferredScheme)://app/"
        
        switch mode {
        case .mnemonic:
            if let mnemonic = mnemonic {
                return "\(mnemonic)"
            }
        case .address:
            var query = "?address=\(address ?? "")"
            if let label = label {
                query += "&label=\(label)"
            }
            return "\(base)address-action/\(query)"
        case .addContact:
            var query = "?address=\(address ?? "")"
            if let label = label {
                query += "&label=\(label)"
            }
            return "\(base)add-contact/\(query)"
        case .editContact:
            var query = "?address=\(address ?? "")"
            if let label = label {
                query += "&label=\(label)"
            }
            return "\(base)edit-contact/\(query)"
        case .addWatchAccount:
            var query = "?address=\(address ?? "")"
            if let label = label {
                query += "&label=\(label)"
            }
            return "\(base)add-watch-account/\(query)"
        case .receiverAccountSelection:
            var query = "?address=\(address ?? "")"
            if let label = label {
                query += "&label=\(label)"
            }
            return "\(base)receiver-account-selection/\(query)"
        case .addressActions:
            var query = "?address=\(address ?? "")"
            if let label = label {
                query += "&label=\(label)"
            }
            return "\(base)address-actions/\(query)"
        case .recoverAddress:
            var query = ""
            if let mnemonic = mnemonic {
                query += "?mnemonic=\(mnemonic)"
            }
            return "\(base)recover-address/\(query)"
            
        case .algosRequest:
            guard let address = address else {
                return base + "asset-transfer/"
            }
            var query = "?assetId=0&receiverAddress=\(address)"
            if let amount = amount {
                query += "&amount=\(amount)"
            }
            if let note = note {
                query += "&note=\(note)"
            }
            if let lockedNote = lockedNote {
                query += "&xnote=\(lockedNote)"
            }
            if let label = label {
                query += "&label=\(label)"
            }
            return "\(base)asset-transfer/\(query)"
            
        case .assetRequest:
            guard let address = address else {
                return base + "asset-transfer/"
            }
            var query = "?receiverAddress=\(address)"
            if let asset = asset {
                query += "&assetId=\(asset)"
            }
            if let amount = amount {
                query += "&amount=\(amount)"
            }
            if let note = note {
                query += "&note=\(note)"
            }
            if let lockedNote = lockedNote {
                query += "&xnote=\(lockedNote)"
            }
            if let label = label {
                query += "&label=\(label)"
            }
            return "\(base)asset-transfer/\(query)"
            
        case .optInRequest:
            var query = ""
            if let asset = asset {
                query += "?assetId=\(asset)"
            }
            if let note = note {
                query += query.isEmpty ? "?note=\(note)" : "&note=\(note)"
            }
            if let lockedNote = lockedNote {
                query += query.isEmpty ? "?xnote=\(lockedNote)" : "&xnote=\(lockedNote)"
            }
            return "\(base)asset-opt-in/\(query)"
            
        case .keyregRequest:
            guard let address = address else {
                return base + "key-reg/"
            }
            var query = "?address=\(address)"
            if let note = note {
                query += "&note=\(note)"
            }
            if let lockedNote = lockedNote {
                query += "&xnote=\(lockedNote)"
            }
            if let fee = keyRegTransactionQRData?.fee {
                query += "&fee=\(fee)"
            }
            if let selectionKey = keyRegTransactionQRData?.selectionKey {
                query += "&selkey=\(selectionKey)"
            }
            if let stateProofKey = keyRegTransactionQRData?.stateProofKey {
                query += "&sprfkey=\(stateProofKey)"
            }
            if let voteKeyDilution = keyRegTransactionQRData?.voteKeyDilution {
                query += "&votekd=\(voteKeyDilution)"
            }
            if let votingKey = keyRegTransactionQRData?.votingKey {
                query += "&votekey=\(votingKey)"
            }
            if let voteFirst = keyRegTransactionQRData?.voteFirst {
                query += "&votefst=\(voteFirst)"
            }
            if let voteLast = keyRegTransactionQRData?.voteLast {
                query += "&votelst=\(voteLast)"
            }
            return "\(base)keyreg/\(query)"
        case .walletConnect:
            var query = ""
            if let walletConnectUrl = walletConnectUrl {
                query += "?walletConnectUrl=\(walletConnectUrl)"
            }
            return "\(base)wallet-connect/\(query)"
        case .assetDetail:
            var query = "?address=\(address ?? "")"
            if let asset = asset {
                query += "&assetId=\(asset)"
            }
            return "\(base)asset-detail/\(query)"
        case .assetInbox:
            var query = "?address=\(address ?? "")"
            return "\(base)asset-inbox/\(query)"
        case .discoverBrowser:
            var query = ""
            if let url = url {
                query += "?url=\(url)"
            }
            return "\(base)discover-browser/\(query)"
        case .discoverPath:
            var query = ""
            if let path = path {
                query += "?path=\(path)"
            }
            return "\(base)discover-path/\(query)"
        case .cardsPath:
            var query = ""
            if let path = path {
                query += "?path=\(path)"
            }
            return "\(base)cards-path/\(query)"
        case .stakingPath:
            var query = ""
            if let path = path {
                query += "?path=\(path)"
            }
            return "\(base)staking-path/\(query)"
        case .buy:
            var query = "?address=\(address ?? "")"
            return "\(base)buy/\(query)"
        case .sell:
            var query = "?address=\(address ?? "")"
            return "\(base)sell/\(query)"
        case .accountDetail:
            var query = "?address=\(address ?? "")"
            return "\(base)account-detail/\(query)"
        }
        return ""
    }
    
    /// Generate QR text using the legacy format (for backward compatibility)
    public func qrTextLegacyFormat() -> String {
        /// <todo>
        /// This should be converted to a builder/generator, not implemented in the model itself.
        let deeplinkConfig = ALGAppTarget.current.deeplinkConfig.qr
        let base = "\(deeplinkConfig.preferredScheme)://"
        switch mode {
        case .mnemonic:
            if let mnemonic = mnemonic {
                return "\(mnemonic)"
            }
        case .address, .addContact, .editContact, .addWatchAccount, .receiverAccountSelection, .addressActions, .assetDetail, .assetInbox, .buy, .sell, .accountDetail:
            guard let address = address else {
                return base
            }
            if let label = label {
                return "\(base)\(address)?\(CodingKeys.label.rawValue)=\(label)"
            }
            return "\(address)"
        case .recoverAddress:
            if let mnemonic = mnemonic {
                return "\(mnemonic)"
            }
        case .walletConnect:
            if let walletConnectUrl = walletConnectUrl {
                return walletConnectUrl
            }
        case .discoverBrowser:
            if let url = url {
                return "\(base)?url=\(url)"
            }
        case .discoverPath:
            if let path = path {
                return "\(base)discover?path=\(path)"
            }
            return "\(base)discover"
        case .cardsPath:
            if let path = path {
                return "\(base)cards?path=\(path)"
            }
            return "\(base)cards"
        case .stakingPath:
            if let path = path {
                return "\(base)staking?path=\(path)"
            }
            return "\(base)staking"
        case .algosRequest:
            guard let address = address else {
                return base
            }
            var query = ""
            if let amount = amount {
                query += "?\(CodingKeys.amount.rawValue)=\(amount)"
            }

            if let note = note {
                query += "&\(CodingKeys.note.rawValue)=\(note)"
            }

            if let lockedNote = lockedNote {
                query += "&\(CodingKeys.lockedNote.rawValue)=\(lockedNote)"
            }

            return "\(base)\(address)\(query)"
        case .assetRequest:
            guard let address = address else {
                return base
            }
            var query = ""
            if let amount = amount {
                query += "?\(CodingKeys.amount.rawValue)=\(amount)"
            }
            
            if let asset = asset, !query.isEmpty {
                query += "&\(CodingKeys.asset.rawValue)=\(asset)"
            }

            if let note = note {
                query += "&\(CodingKeys.note.rawValue)=\(note)"
            }

            if let lockedNote = lockedNote {
                query += "&\(CodingKeys.lockedNote.rawValue)=\(lockedNote)"
            }

            return "\(base)\(address)\(query)"
        case .optInRequest:
            var query = ""

            if let asset = asset,
               !query.isEmpty {
                query += "?\(CodingKeys.amount.rawValue)=0"
                query += "&\(CodingKeys.asset.rawValue)=\(asset)"
            }

            return "\(base)\(query)"
        case .keyregRequest:
            guard let address = address else { return base }
            
            var query = ""
            query += "?\(CodingKeys.type.rawValue)=keyreg"
            
            if let note = note {
                query += "&\(CodingKeys.note.rawValue)=\(note)"
            }

            if let fee = keyRegTransactionQRData?.fee {
                query += "&\(KeyRegTransactionQRData.CodingKeys.fee.rawValue)=\(fee)"
            }

            if let selectionKey = keyRegTransactionQRData?.selectionKey {
                query += "&\(KeyRegTransactionQRData.CodingKeys.selectionKey.rawValue)=\(selectionKey)"
            }
            
            if let stateProofKey = keyRegTransactionQRData?.stateProofKey {
                query += "&\(KeyRegTransactionQRData.CodingKeys.stateProofKey.rawValue)=\(stateProofKey)"
            }

            if let voteKeyDilution = keyRegTransactionQRData?.voteKeyDilution {
                query += "&\(KeyRegTransactionQRData.CodingKeys.voteKeyDilution.rawValue)=\(voteKeyDilution)"
            }
            
            if let votingKey = keyRegTransactionQRData?.votingKey {
                query += "&\(KeyRegTransactionQRData.CodingKeys.votingKey.rawValue)=\(votingKey)"
            }
            
            if let voteFirst = keyRegTransactionQRData?.voteFirst {
                query += "&\(KeyRegTransactionQRData.CodingKeys.voteFirst.rawValue)=\(voteFirst)"
            }

            if let voteLast = keyRegTransactionQRData?.voteLast {
                query += "&\(KeyRegTransactionQRData.CodingKeys.voteLast.rawValue)=\(voteLast)"
            }

            return "\(base)\(address)\(query)"
        }
        return ""
    }
    
    /// Generate universal link using the new app-based format
    public func universalLinkAppFormat() -> String {
        let universalLinkConfig = ALGAppTarget.current.universalLinkConfig
        let base = universalLinkConfig.url.absoluteString
        
        // Remove trailing slash if present
        let cleanBase = base.hasSuffix("/") ? String(base.dropLast()) : base
        let appBase = "\(cleanBase)/qr/perawallet/app/"
        
        switch mode {
        case .mnemonic:
            if let mnemonic = mnemonic {
                return "\(mnemonic)"
            }
        case .address:
            var query = "?address=\(address ?? "")"
            if let label = label {
                query += "&label=\(label)"
            }
            return "\(appBase)address-action/\(query)"
        case .addContact:
            var query = "?address=\(address ?? "")"
            if let label = label {
                query += "&label=\(label)"
            }
            return "\(appBase)add-contact/\(query)"
        case .editContact:
            var query = "?address=\(address ?? "")"
            if let label = label {
                query += "&label=\(label)"
            }
            return "\(appBase)edit-contact/\(query)"
        case .addWatchAccount:
            var query = "?address=\(address ?? "")"
            if let label = label {
                query += "&label=\(label)"
            }
            return "\(appBase)add-watch-account/\(query)"
        case .receiverAccountSelection:
            var query = "?address=\(address ?? "")"
            if let label = label {
                query += "&label=\(label)"
            }
            return "\(appBase)receiver-account-selection/\(query)"
        case .addressActions:
            var query = "?address=\(address ?? "")"
            if let label = label {
                query += "&label=\(label)"
            }
            return "\(appBase)address-actions/\(query)"
        case .recoverAddress:
            var query = ""
            if let mnemonic = mnemonic {
                query += "?mnemonic=\(mnemonic)"
            }
            return "\(appBase)recover-address/\(query)"
            
        case .algosRequest:
            guard let address = address else {
                return appBase + "asset-transfer/"
            }
            var query = "?assetId=0&receiverAddress=\(address)"
            if let amount = amount {
                query += "&amount=\(amount)"
            }
            if let note = note {
                query += "&note=\(note)"
            }
            if let lockedNote = lockedNote {
                query += "&xnote=\(lockedNote)"
            }
            if let label = label {
                query += "&label=\(label)"
            }
            return "\(appBase)asset-transfer/\(query)"
            
        case .assetRequest:
            guard let address = address else {
                return appBase + "asset-transfer/"
            }
            var query = "?receiverAddress=\(address)"
            if let asset = asset {
                query += "&assetId=\(asset)"
            }
            if let amount = amount {
                query += "&amount=\(amount)"
            }
            if let note = note {
                query += "&note=\(note)"
            }
            if let lockedNote = lockedNote {
                query += "&xnote=\(lockedNote)"
            }
            if let label = label {
                query += "&label=\(label)"
            }
            return "\(appBase)asset-transfer/\(query)"
            
        case .optInRequest:
            var query = ""
            if let asset = asset {
                query += "?assetId=\(asset)"
            }
            if let note = note {
                query += query.isEmpty ? "?note=\(note)" : "&note=\(note)"
            }
            if let lockedNote = lockedNote {
                query += query.isEmpty ? "?xnote=\(lockedNote)" : "&xnote=\(lockedNote)"
            }
            return "\(appBase)asset-opt-in/\(query)"
            
        case .keyregRequest:
            guard let address = address else {
                return appBase + "key-reg/"
            }
            var query = "?address=\(address)"
            if let note = note {
                query += "&note=\(note)"
            }
            if let lockedNote = lockedNote {
                query += "&xnote=\(lockedNote)"
            }
            if let fee = keyRegTransactionQRData?.fee {
                query += "&fee=\(fee)"
            }
            if let selectionKey = keyRegTransactionQRData?.selectionKey {
                query += "&selkey=\(selectionKey)"
            }
            if let stateProofKey = keyRegTransactionQRData?.stateProofKey {
                query += "&sprfkey=\(stateProofKey)"
            }
            if let voteKeyDilution = keyRegTransactionQRData?.voteKeyDilution {
                query += "&votekd=\(voteKeyDilution)"
            }
            if let votingKey = keyRegTransactionQRData?.votingKey {
                query += "&votekey=\(votingKey)"
            }
            if let voteFirst = keyRegTransactionQRData?.voteFirst {
                query += "&votefst=\(voteFirst)"
            }
            if let voteLast = keyRegTransactionQRData?.voteLast {
                query += "&votelst=\(voteLast)"
            }
            return "\(appBase)keyreg/\(query)"
        case .walletConnect:
            var query = ""
            if let walletConnectUrl = walletConnectUrl {
                query += "?walletConnectUrl=\(walletConnectUrl)"
            }
            return "\(appBase)wallet-connect/\(query)"
        case .assetDetail:
            var query = "?address=\(address ?? "")"
            if let asset = asset {
                query += "&assetId=\(asset)"
            }
            return "\(appBase)asset-detail/\(query)"
        case .assetInbox:
            var query = "?address=\(address ?? "")"
            return "\(appBase)asset-inbox/\(query)"
        case .discoverBrowser:
            var query = ""
            if let url = url {
                query += "?url=\(url)"
            }
            return "\(appBase)discover-browser/\(query)"
        case .discoverPath:
            var query = ""
            if let path = path {
                query += "?path=\(path)"
            }
            return "\(appBase)discover-path/\(query)"
        case .cardsPath:
            var query = ""
            if let path = path {
                query += "?path=\(path)"
            }
            return "\(appBase)cards-path/\(query)"
        case .stakingPath:
            var query = ""
            if let path = path {
                query += "?path=\(path)"
            }
            return "\(appBase)staking-path/\(query)"
        case .buy:
            var query = "?address=\(address ?? "")"
            return "\(appBase)buy/\(query)"
        case .sell:
            var query = "?address=\(address ?? "")"
            return "\(appBase)sell/\(query)"
        case .accountDetail:
            var query = "?address=\(address ?? "")"
            return "\(appBase)account-detail/\(query)"
        }
        return ""
    }
}

extension QRText {
    public enum CodingKeys: String, CodingKey {
        case mode = "mode"
        case version = "version"
        case address = "address"
        case mnemonic = "mnemonic"
        case amount = "amount"
        case label = "label"
        case asset = "asset"
        case note = "note"
        case lockedNote = "xnote"
        case type = "type"
        case fee = "fee"
        case selectionKey = "selkey"
        case stateProofKey = "sprfkey"
        case voteKeyDilution = "votekd"
        case votingKey = "votekey"
        case voteFirst = "votefst"
        case voteLast = "votelst"
        case walletConnectUrl = "walletConnectUrl"
        case url = "url"
        case path = "path"
        
        public static func == (lhs: CodingKeys, rhs: CodingKeys) -> Bool {
            lhs.rawValue == rhs.rawValue
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }
}

public struct KeyRegTransactionQRData: Codable {
    public var fee: UInt64?
    public var selectionKey: String?
    public var stateProofKey: String?
    public var voteKeyDilution: UInt64?
    public var votingKey: String?
    public var voteFirst: UInt64?
    public var voteLast: UInt64?
    
    public init(
        fee: UInt64? = nil,
        selectionKey: String? = nil,
        stateProofKey: String? = nil,
        voteKeyDilution: UInt64? = nil,
        votingKey: String? = nil,
        voteFirst: UInt64? = nil,
        voteLast: UInt64? = nil
    ) {
        self.fee = fee
        self.selectionKey = selectionKey
        self.stateProofKey = stateProofKey
        self.voteKeyDilution = voteKeyDilution
        self.votingKey = votingKey
        self.voteFirst = voteFirst
        self.voteLast = voteLast
    }
}

extension KeyRegTransactionQRData {
    enum CodingKeys: String, CodingKey {
        case fee = "fee"
        case selectionKey = "selkey"
        case stateProofKey = "sprfkey"
        case voteKeyDilution = "votekd"
        case votingKey = "votekey"
        case voteFirst = "votefst"
        case voteLast = "votelst"
    }
}

public enum QRMode {
    case address
    case mnemonic
    case algosRequest
    case assetRequest
    case optInRequest
    case keyregRequest
    case addContact
    case editContact
    case addWatchAccount
    case receiverAccountSelection
    case addressActions
    case recoverAddress
    case walletConnect
    case assetDetail
    case assetInbox
    case discoverBrowser
    case discoverPath
    case cardsPath
    case stakingPath
    case buy
    case sell
    case accountDetail
}
