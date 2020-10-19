//
//  TransactionConfigurator.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.10.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct TransactionConfigurator {
    let account: Account
    let assetDetail: AssetDetail?
    let transaction: TransactionItem
    var contact: Contact?
}
