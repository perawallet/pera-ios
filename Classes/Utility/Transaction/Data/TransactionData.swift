//
//  TransactionData.swift

import Foundation

class TransactionData {
    private(set) var unsignedTransaction: Data?
    private(set) var signedTransaction: Data?

    func setUnsignedTransaction(_ data: Data) {
        unsignedTransaction = data
    }

    func setSignedTransaction(_ data: Data) {
        signedTransaction = data
    }
}
