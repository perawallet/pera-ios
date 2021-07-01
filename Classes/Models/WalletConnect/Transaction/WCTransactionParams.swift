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
//   WCTransactionParams.swift

import Magpie

class WCTransactionParams: Model {
    private(set) var unparsedTransaction: Data? // Transaction that is not parsed for msgpack, needs to be used for signing
    var transaction: WCTransaction?
    let signers: [String]?

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        signers = try container.decodeIfPresent([String].self, forKey: .signers)
        if let transactionMsgpack = try container.decodeIfPresent(Data.self, forKey: .transaction) {
            unparsedTransaction = transactionMsgpack
            transaction = parseTransaction(from: transactionMsgpack)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(transaction, forKey: .transaction)
        try container.encodeIfPresent(signers, forKey: .signers)
    }
}

extension WCTransactionParams {
    private enum CodingKeys: String, CodingKey {
        case transaction = "txn"
        case signers = "signers"
    }
}

extension WCTransactionParams {
    private func parseTransaction(from msgpack: Data) -> WCTransaction? {
        var error: NSError?
        let jsonString = AlgorandSDK().msgpackToJSON(msgpack, error: &error)

        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }

        return try? JSONDecoder().decode(WCTransaction.self, from: jsonData)
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
}

extension WCTransactionParams {
    enum Signer {
        case sender // Transaction should be signed by the sender
        case unsignable // Transaction should not be signed
        case current(address: String?) // Transaction should be signed by the address in the list
        case multisig // Transaction requires multisignature
    }
}
