//
//  RoundDetail.swift
//  algorand
//
//  Created by Omer Emre Aslan on 22.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class RoundDetail: Model {
    let lastRound: Int64
    let nextVersionRound: Int64
}

extension RoundDetail {
    private enum CodingKeys: String, CodingKey {
        case lastRound = "last-round"
        case nextVersionRound = "next-version-round"
    }
}
