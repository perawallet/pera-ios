//
//  AlgorandError.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct AlgorandError: Mappable & Encodable {
    let type: String
    let message: String?
}

extension AlgorandError {
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case message = "fallback_message"
    }
}
