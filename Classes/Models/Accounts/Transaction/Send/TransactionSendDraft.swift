//
//  TransactionSendDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

protocol TransactionSendDraft {
    var from: Account { get set }
    var toAccount: String? { get set }
    var amount: Double? { get set }
    var fee: Int64? { get set }
    var isMaxTransaction: Bool { get set }
    var identifier: String? { get set }
}
