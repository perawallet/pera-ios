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
//   WCTransaction.swift

import Magpie

class WCTransaction: Model {
    let fee: Int64?
    let firstValidRound: Int64?
    let lastValidRound: Int64?
    let genesisHash: String?
    let note: Data?

    private(set) var sender: String?
    let type: Transaction.TransferType?

    private let algosAmount: Int64?
    private let assetAmount: Int64?
    var amount: Int64 {
        return assetAmount ?? algosAmount ?? 0
    }

    private var assetReceiver: String?
    private var algosReceiver: String?
    var receiver: String? {
        return assetReceiver ?? algosReceiver
    }

    private var assetCloseAddress: String?
    private var algosCloseAddress: String?
    var closeAddress: String? {
        return assetCloseAddress ?? algosCloseAddress
    }

    private(set) var rekeyAddress: String?
    let assetId: Int64?

    let appCallArguments: [String]?
    let appCallOnComplete: AppCallOnComplete?
    let appCallId: Int64?

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fee = try container.decodeIfPresent(Int64.self, forKey: .fee)
        firstValidRound = try container.decodeIfPresent(Int64.self, forKey: .firstValidRound)
        lastValidRound = try container.decodeIfPresent(Int64.self, forKey: .lastValidRound)
        genesisHash = try container.decodeIfPresent(String.self, forKey: .genesisHash)
        note = try container.decodeIfPresent(Data.self, forKey: .note)
        type = try container.decodeIfPresent(Transaction.TransferType.self, forKey: .type)
        assetAmount = try container.decodeIfPresent(Int64.self, forKey: .assetAmount)
        algosAmount = try container.decodeIfPresent(Int64.self, forKey: .algosAmount)
        assetId = try container.decodeIfPresent(Int64.self, forKey: .assetId)
        appCallArguments = try container.decodeIfPresent([String].self, forKey: .appCallArguments)
        appCallOnComplete = try container.decodeIfPresent(AppCallOnComplete.self, forKey: .appCallOnComplete)
        appCallId = try container.decodeIfPresent(Int64.self, forKey: .appCallId)

        if let senderMsgpack = try container.decodeIfPresent(Data.self, forKey: .sender) {
            sender = parseAddress(from: senderMsgpack)
        }

        if let algosReceiverMsgpack = try container.decodeIfPresent(Data.self, forKey: .algosReceiver) {
            algosReceiver = parseAddress(from: algosReceiverMsgpack)
        }

        if let assetCloseAddressMsgpack = try container.decodeIfPresent(Data.self, forKey: .assetCloseAddress) {
            assetCloseAddress = parseAddress(from: assetCloseAddressMsgpack)
        }

        if let algosCloseAddressMsgpack = try container.decodeIfPresent(Data.self, forKey: .algosCloseAddress) {
            algosCloseAddress = parseAddress(from: algosCloseAddressMsgpack)
        }

        if let rekeyAddressMsgpack = try container.decodeIfPresent(Data.self, forKey: .rekeyAddress) {
            rekeyAddress = parseAddress(from: rekeyAddressMsgpack)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(fee, forKey: .fee)
        try container.encodeIfPresent(firstValidRound, forKey: .firstValidRound)
        try container.encodeIfPresent(lastValidRound, forKey: .lastValidRound)
        try container.encodeIfPresent(genesisHash, forKey: .genesisHash)
        try container.encodeIfPresent(note, forKey: .note)
        try container.encodeIfPresent(sender, forKey: .sender)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(assetAmount, forKey: .assetAmount)
        try container.encodeIfPresent(algosAmount, forKey: .algosAmount)
        try container.encodeIfPresent(assetReceiver, forKey: .assetReceiver)
        try container.encodeIfPresent(algosReceiver, forKey: .algosReceiver)
        try container.encodeIfPresent(assetCloseAddress, forKey: .assetCloseAddress)
        try container.encodeIfPresent(algosCloseAddress, forKey: .algosCloseAddress)
        try container.encodeIfPresent(rekeyAddress, forKey: .rekeyAddress)
        try container.encodeIfPresent(assetId, forKey: .assetId)
        try container.encodeIfPresent(appCallArguments, forKey: .appCallArguments)
        try container.encodeIfPresent(appCallOnComplete, forKey: .appCallOnComplete)
        try container.encodeIfPresent(appCallId, forKey: .appCallId)
    }
}

extension WCTransaction {
    var transactionType: WCTransactionType {
        if isAlgosTransaction {
            return .algos
        }

        if isAssetTransaction {
            return .asset
        }

        if isAssetAdditionTransaction {
            return .assetAddition
        }

        if isAppCallTransaction {
            return .appCall
        }

        return .group
    }

    var isAlgosTransaction: Bool {
        return type == .payment && assetId == nil
    }

    var isAssetTransaction: Bool {
        return type == .assetTransfer
    }

    var isAssetAdditionTransaction: Bool {
        return type == .assetTransfer && assetAmount == 0 && sender == assetReceiver
    }

    var isAppCallTransaction: Bool {
        return type == .applicationCall
    }

    var isRekeyTransaction: Bool {
        return rekeyAddress != nil
    }

    var isCloseTransaction: Bool {
        return closeAddress != nil
    }

    func noteRepresentation() -> String? {
        guard let noteData = note, !noteData.isEmpty else {
            return nil
        }

        return String(data: noteData, encoding: .utf8) ?? noteData.base64EncodedString()
    }
}

extension WCTransaction {
    private func parseAddress(from msgpack: Data) -> String? {
        var error: NSError?
        let addressString = AlgorandSDK().addressFromPublicKey(msgpack, error: &error)
        return error == nil ? addressString : nil
    }
}

extension WCTransaction {
    enum AppCallOnComplete: Int, Codable {
        case noOp = 0
        case optIn = 1
        case close = 2
        case clearState = 3
        case update = 4
        case delete = 5
    }
}

extension WCTransaction {
    private enum CodingKeys: String, CodingKey {
        case fee = "fee"
        case firstValidRound = "fv"
        case lastValidRound = "lv"
        case genesisHash = "gh"
        case note = "note"
        case sender = "snd"
        case type = "type"
        case assetAmount = "amt"
        case algosAmount = "aamt"
        case assetReceiver = "arcv"
        case algosReceiver = "rcv"
        case assetCloseAddress = "aclose"
        case algosCloseAddress = "close"
        case rekeyAddress = "rekey"
        case assetId = "xaid"
        case appCallArguments = "apaa"
        case appCallOnComplete = "apan"
        case appCallId = "apid"
    }
}
