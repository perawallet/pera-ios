//
//  RekeyedAccountQuery.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

struct RekeyedAccountQuery: ObjectQuery {
    let authAddress: String
    
    var queryParams: [QueryParam] {
        var params: [QueryParam] = []
        params.append(.init(.authAddress, authAddress))
        return params
    }
}
