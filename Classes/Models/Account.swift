//
//  Account.swift
//  algorand
//
//  Created by Omer Emre Aslan on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

enum AccountStatus: String, Mappable {
    case offline = "Offline"
    case online = "Online"
    case notParticipating = "NotParticipating"
}

class Account: Mappable {
    let address: String
    let amount: UInt64
    let status: AccountStatus
}
