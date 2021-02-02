//
//  TransactionViewModelDependencies.swift

import Foundation

struct TransactionViewModelDependencies {
    let account: Account
    let assetDetail: AssetDetail?
    let transaction: TransactionItem
    var contact: Contact?
}
