//
//  VerifiedAssetQuery.swift

import Magpie

struct LimitQuery: ObjectQuery {
    var limit = "all"
    
    var queryParams: [QueryParam] {
        var params: [QueryParam] = []
        params.append(.init(.limit, limit))
        return params
    }
}
