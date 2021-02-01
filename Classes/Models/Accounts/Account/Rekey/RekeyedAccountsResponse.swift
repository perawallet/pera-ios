//
//  RekeyedAccountsResponse.swift

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
