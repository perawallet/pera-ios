//
//  TransactionSignable.swift

import Foundation

protocol TransactionSignable: class {
    func sign(_ data: Data?, with privateData: Data?) -> Data?
}
