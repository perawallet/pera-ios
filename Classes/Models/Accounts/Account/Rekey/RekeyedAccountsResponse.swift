//
//  RekeyedAccountsResponse.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

class RekeyedAccountsResponse: Model {
    let accounts: [Account]
    let currentRound: Int64
    let nextToken: String?
}

extension RekeyedAccountsResponse {
    enum CodingKeys: String, CodingKey {
        case accounts = "accounts"
        case currentRound = "current-round"
        case nextToken = "next-token"
    }
}
