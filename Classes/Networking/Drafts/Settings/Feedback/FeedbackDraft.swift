//
//  FeedbackDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct FeedbackDraft: JSONKeyedBody {
    typealias Key = RequestParameter
    
    let note: String
    let category: String
    let email: String
    let address: String?
    
    func decoded() -> [Pair]? {
        var pairs = [
            Pair(key: .note, value: note),
            Pair(key: .category, value: category),
            Pair(key: .email, value: email)
        ]
        
        if let address = address {
            pairs.append(Pair(key: .address, value: address))
        }
        
        return pairs
    }
}
