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
//  QRText.swift

import Foundation

final class QRText: Codable {
    let mode: QRMode
    let version = "1.0"
    let address: String?
    var mnemonic: String?
    var amount: UInt64?
    var label: String?
    var asset: Int64?
    var note: String?
    var lockedNote: String?
    let type: String?
    var keyRegTransactionQRData: KeyRegTransactionQRData?
    
    init(
        mode: QRMode,
        address: String? = nil,
        mnemonic: String? = nil,
        amount: UInt64? = nil,
        label: String? = nil,
        asset: Int64? = nil,
        note: String? = nil,
        lockedNote: String? = nil,
        keyRegTransactionQRData: KeyRegTransactionQRData? = nil,
        type: String? = nil
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
    }
    
    required init(from decoder: Decoder) throws {
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
    
    func encode(to encoder: Encoder) throws {
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
        }
    }

    class func build(for address: String?, with queryParameters: [String: String]?) -> Self? {
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
    func qrText() -> String {
        /// <todo>
        /// This should be converted to a builder/generator, not implemented in the model itself.
        let deeplinkConfig = ALGAppTarget.current.deeplinkConfig.qr
        let base = "\(deeplinkConfig.preferredScheme)://"
        switch mode {
        case .mnemonic:
            if let mnemonic = mnemonic {
                return "\(mnemonic)"
            }
        case .address:
            guard let address = address else {
                return base
            }
            if let label = label {
                return "\(base)\(address)?\(CodingKeys.label.rawValue)=\(label)"
            }
            return "\(address)"
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
}

extension QRText {
    enum CodingKeys: String, CodingKey {
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
    }
}

struct KeyRegTransactionQRData: Codable {
    var fee: UInt64?
    var selectionKey: String?
    var stateProofKey: String?
    var voteKeyDilution: UInt64?
    var votingKey: String?
    var voteFirst: UInt64?
    var voteLast: UInt64?
    
    init(
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
