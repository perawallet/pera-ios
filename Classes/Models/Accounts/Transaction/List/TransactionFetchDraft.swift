//
//  TransactionFetchDraft.swift

import Foundation

struct TransactionFetchDraft {
    let account: Account
    let dates: (from: Date?, to: Date?)
    let nextToken: String?
    let assetId: String?
    let limit: Int?
}
