//
//  TransactionDataBuildable.swift

import Foundation

protocol TransactionDataBuildable: class {
    var params: TransactionParams? { get }
    var draft: TransactionSendDraft? { get }

    func composeData() -> Data?
}
