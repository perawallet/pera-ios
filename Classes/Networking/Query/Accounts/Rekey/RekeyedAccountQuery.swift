//
//  RekeyedAccountQuery.swift

import Magpie

struct RekeyedAccountQuery: ObjectQuery {
    let authAddress: String
    
    var queryParams: [QueryParam] {
        var params: [QueryParam] = []
        params.append(.init(.authAddress, authAddress))
        return params
    }
}
