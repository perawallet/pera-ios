//
//  IndexerError.swift

import Magpie

class IndexerError: Model {
    let message: String
}

extension IndexerError {
    func containsAccount(_ address: String) -> Bool {
        return message.contains(address)
    }
}
