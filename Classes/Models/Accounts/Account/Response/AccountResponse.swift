//
//  AccountResponse.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

class AccountResponse: Model {
    let account: Account
    let currentRound: Int64
}

extension AccountResponse {
    enum CodingKeys: String, CodingKey {
        case account = "account"
        case currentRound = "current-round"
    }
}
