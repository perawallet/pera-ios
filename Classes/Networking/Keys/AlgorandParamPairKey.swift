//
//  AlgorandParamPairKey.swift
//  algorand
//
//  Created by Omer Emre Aslan on 15.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

enum AlgorandParamPairKey: String, CodingKey {
    case address = "address"
    case firstRound = "firstRound"
    case lastRound = "lastRound"
    case accessToken = "access_token"
    case top = "top"
    case max = "max"
    case from = "from"
    case to = "to"
}

extension AlgorandParamPairKey: ParamsPairKey {
    var description: String {
        return rawValue
    }
    
    var defaultValue: ParamsPairValue? {
        switch self {
        default:
            return nil
        }
    }
}
