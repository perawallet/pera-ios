//
//  CoinlistTokenQuery.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 3.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct CoinlistTokenQuery: Query {
    typealias Key = RequestParameter
    
    let token: String
    let top: Int?
    
    func decoded() -> [Pair]? {
        var pairs = [Pair(key: .accessToken, value: .some(token))]
        if let top = top {
            pairs.append(contentsOf: [Pair(key: .top, value: .some(top))])
        }
        return pairs
    }
}
