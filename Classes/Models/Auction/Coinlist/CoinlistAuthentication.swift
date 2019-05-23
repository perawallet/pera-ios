//
//  CoinlistAuthentication.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class CoinlistAuthentication: Mappable {
    
    let accessToken: String
}

extension CoinlistAuthentication {
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
