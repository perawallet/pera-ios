//
//  TransactionSignature.swift

import Magpie

class TransactionSignature: Model {
    let signature: String?
}

extension TransactionSignature {
    enum CodingKeys: String, CodingKey {
        case signature = "sig"
    }
}
