//
//  TransactionsDraft.swift

import Foundation

protocol TransactionDraft {
    var from: Account { get set }
    var transactionParams: TransactionParams { get set }
}
