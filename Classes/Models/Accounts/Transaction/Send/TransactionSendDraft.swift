//
//  TransactionSendDraft.swift

import Foundation

protocol TransactionSendDraft {
    var from: Account { get set }
    var toAccount: String? { get set }
    var amount: Double? { get set }
    var fee: Int64? { get set }
    var isMaxTransaction: Bool { get set }
    var identifier: String? { get set }
    var note: String? { get set }
}
