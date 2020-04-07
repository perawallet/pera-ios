//
//  TransactionsDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 22.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

protocol TransactionDraft {
    var from: Account { get set }
    var transactionParams: TransactionParams { get set }
}
