//
//  CursorQuery.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 20.07.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

struct CursorQuery: ObjectQuery {
    let cursor: String?
    
    var queryParams: [QueryParam] {
        var params: [QueryParam] = []
        if let cursor = cursor {
            params.append(.init(.cursor, cursor))
        }
        return params
    }
}
