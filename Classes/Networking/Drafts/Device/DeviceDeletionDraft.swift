//
//  DeviceDeletionDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 16.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

struct DeviceDeletionDraft: JSONKeyedBody {
    typealias Key = RequestParameter
    
    let pushToken: String
    
    func decoded() -> [Pair]? {
        return [
            Pair(key: .pushToken, value: pushToken)
        ]
    }
}
