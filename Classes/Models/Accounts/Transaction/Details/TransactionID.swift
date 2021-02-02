//
//  TransactionID.swift

import Magpie

class TransactionID: Model {
    let identifier: String
    
    init(identifier: String) {
        self.identifier = identifier
    }
}

extension TransactionID {
    private enum CodingKeys: String, CodingKey {
        case identifier = "txId"
    }
}
