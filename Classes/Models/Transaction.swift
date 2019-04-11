//
//  Transaction.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

struct Transaction: Codable {
    let fromAccount: Account
    let amount: Double
    var identifier: String?
    var fee: Int64?
}
