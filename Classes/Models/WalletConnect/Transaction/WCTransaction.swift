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
    let note: String?

    let sender: String?
    let type: Transaction.TransferType?

    private let algosAmount: Int64?
    private let assetAmount: Int64?
    var amount: Int64 {
        return assetAmount ?? algosAmount ?? 0
    }

    private let assetReceiver: String?
    private let algosReceiver: String?
    var receiver: String? {
        return assetReceiver ?? algosReceiver
    }

    private let assetCloseAddress: String?
    private let algosCloseAddress: String?
    var closeAddress: String? {
        return assetCloseAddress ?? algosCloseAddress
    }

    let rekeyAddress: String?
    let assetId: Int64?

    let appCallList: [String]?
    let apppCallNValue: Int64?
    let appCallId: Int64?
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
        case appCallList = "apaa"
        case apppCallNValue = "apan"
        case appCallId = "apid"
    }
}
