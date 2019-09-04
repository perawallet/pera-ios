//
//  CoinlistAuthentication.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class CoinlistAuthentication: Model {
    let accessToken: String
}

extension CoinlistAuthentication {
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
