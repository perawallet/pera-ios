//
//  TransactionsQuery.swift

import Magpie

struct TransactionsQuery: ObjectQuery {
    let limit: Int?
    let from: String?
    let to: String?
    let next: String?
    let assetId: String?
    
    var queryParams: [QueryParam] {
        var params: [QueryParam] = []
        if let limit = limit {
            params.append(.init(.limit, limit))
        }
        
        if let from = from,
            let to = to {
            params.append(.init(.afterTime, from))
            params.append(.init(.beforeTime, to))
        }
        
        if let next = next {
            params.append(.init(.next, next))
        }
        
        if let assetId = assetId {
            params.append(.init(.assetIdFilter, assetId))
        }
        
        return params
    }
}
