//
//  VerifiedAssetQuery.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 6.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

struct LimitQuery: ObjectQuery {
    var limit = "all"
    
    var queryParams: [QueryParam] {
        var params: [QueryParam] = []
        params.append(.init(.limit, limit))
        return params
    }
}
