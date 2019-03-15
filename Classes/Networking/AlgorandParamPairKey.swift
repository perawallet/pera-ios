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
