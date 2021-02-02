//
//  CursorQuery.swift

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
