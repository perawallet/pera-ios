//
//  Participation.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.10.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class Participation: Model {
    var partpkb64: String?
    
    enum CodingKeys: String, CodingKey {
        case partpkb64 = "partpkb64"
    }
}

extension Participation: Encodable { }
