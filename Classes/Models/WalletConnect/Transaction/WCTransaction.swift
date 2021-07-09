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
    private(set) var unparsedTransactionDetail: Data? // Transaction that is not parsed for msgpack, needs to be used for signing
    var transactionDetail: WCTransactionDetail?
    let signers: [String]?
    let multisigMetadata: WCMultisigMetadata?
    let message: String?
    let authAddress: String?

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        signers = try container.decodeIfPresent([String].self, forKey: .signers)
        multisigMetadata = try container.decodeIfPresent(WCMultisigMetadata.self, forKey: .multisigMetadata)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        authAddress = try container.decodeIfPresent(String.self, forKey: .authAddress)
        if let transactionMsgpack = try container.decodeIfPresent(Data.self, forKey: .transaction) {
            unparsedTransactionDetail = transactionMsgpack
            transactionDetail = parseTransaction(from: transactionMsgpack)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(transactionDetail, forKey: .transaction)
        try container.encodeIfPresent(signers, forKey: .signers)
        try container.encodeIfPresent(multisigMetadata, forKey: .multisigMetadata)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(authAddress, forKey: .authAddress)
    }
}

extension WCTransaction {
    private enum CodingKeys: String, CodingKey {
        case transaction = "txn"
        case signers = "signers"
        case multisigMetadata = "msig"
        case message = "message"
        case authAddress = "authAddr"
    }
}

extension WCTransaction {
    private func parseTransaction(from msgpack: Data) -> WCTransactionDetail? {
        var error: NSError?
        let jsonString = AlgorandSDK().msgpackToJSON(msgpack, error: &error)

        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }

        return try? JSONDecoder().decode(WCTransactionDetail.self, from: jsonData)
    }

    func signer() -> Signer {
        guard let signers = signers else {
            return .sender
        }

        if signers.isEmpty {
            return .unsignable
        } else if signers.count == 1 {
            return .current(address: signers.first)
        } else {
            return .multisig
        }
    }

    var hasSameSignerWithAuthAddress: Bool {
        switch signer() {
        case let .current(address):
            return authAddress == address
        default:
            return false
        }
    }

    var isValidAuthAddress: Bool {
        return authAddress == transactionDetail?.sender || hasSameSignerWithAuthAddress
    }
}

extension WCTransaction {
    enum Signer {
        case sender // Transaction should be signed by the sender
        case unsignable // Transaction should not be signed
        case current(address: String?) // Transaction should be signed by the address in the list
        case multisig // Transaction requires multisignature
    }
}
