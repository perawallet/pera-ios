//
//  RoundDetail.swift

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
