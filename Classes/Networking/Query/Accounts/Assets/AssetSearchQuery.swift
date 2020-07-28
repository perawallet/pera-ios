//
//  AssetFetchQuery.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct AssetSearchQuery: Query {
    typealias Key = RequestParameter
    
    let status: AssetSearchFilter
    let query: String?
    let limit: Int
    let offset: Int
    
    func decoded() -> [Pair]? {
        var pairs = [Pair(key: .limit, value: .some(limit)), Pair(key: .offset, value: .some(offset))]
        if let query = query {
            pairs.append(Pair(key: .query, value: .some(query)))
        }
        
        switch status {
        case .all:
            return pairs
        default:
            if let statusValue = status.stringValue {
                pairs.append(Pair(key: .status, value: .some(statusValue)))
            }
            return pairs
        }
    }
}

struct TransactionSearchQuery: Query {
    typealias Key = RequestParameter
    
    let id: String?
    
    func decoded() -> [Pair]? {
        if let id = id {
            return [Pair(key: .transactionDetailId, value: .some(id))]
        }
        
        return nil
    }
}
