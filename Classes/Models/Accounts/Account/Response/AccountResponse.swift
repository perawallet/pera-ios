//
//  AccountResponse.swift

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
