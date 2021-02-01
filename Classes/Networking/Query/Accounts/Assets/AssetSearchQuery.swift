//
//  AssetFetchQuery.swift

import Magpie

struct AssetSearchQuery: ObjectQuery {
    let status: AssetSearchFilter
    let query: String?
    let limit: Int
    let offset: Int
    
    var queryParams: [QueryParam] {
        var params: [QueryParam] = []
        params.append(.init(.limit, limit))
        params.append(.init(.offset, offset))
        
        if let query = query {
            params.append(.init(.query, query))
        }
        
        switch status {
        case .all:
            return params
        default:
            if let statusValue = status.stringValue {
                params.append(.init(.status, statusValue))
            }
            return params
        }
    }
}

struct TransactionSearchQuery: ObjectQuery {
    let id: String?
    
    var queryParams: [QueryParam] {
        var params: [QueryParam] = []
        if let id = id {
            params.append(.init(.transactionDetailId, id))
        }
        return params
    }
}
