//
//  CoinlistAuthenticationDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct CoinlistAuthenticationDraft: JSONBody {
    typealias Key = RequestParameter
    
    let code: String
    let grantType: String
    let redirectURI: String
    
    func decoded() -> [Pair]? {
        return [
            Pair(key: .clientId, value: Environment.current.coinlistClientId),
            Pair(key: .clientSecret, value: Environment.current.coinlistClientSecret),
            Pair(key: .code, value: code),
            Pair(key: .grantType, value: grantType),
            Pair(key: .redirectUri, value: redirectURI)
        ]
    }
}
