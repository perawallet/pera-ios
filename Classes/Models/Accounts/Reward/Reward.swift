//
//  Reward.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

struct Reward: TransactionItem {
    let amount: Int64
    let date: Date?
}
