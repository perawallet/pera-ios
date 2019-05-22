//
//  RoundDetail.swift
//  algorand
//
//  Created by Omer Emre Aslan on 22.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class RoundDetail: Mappable {
    
    let lastRound: Int64
    let nextConsensusVersionRound: Int64
    
    enum CodingKeys: String, CodingKey {
        case lastRound = "lastRound"
        case nextConsensusVersionRound = "nextConsensusVersionRound"
    }
}
