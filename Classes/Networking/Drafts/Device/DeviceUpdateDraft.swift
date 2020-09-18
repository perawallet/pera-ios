//
//  DeviceUpdateDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 16.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

struct DeviceUpdateDraft: JSONKeyedBody {
    typealias Key = RequestParameter
    
    let id: String
    let pushToken: String?
    let platform = "ios"
    let model = UIDevice.current.model
    let locale = Locale.current.languageCode ?? "en"
    var accounts: [String] = []
    
    func decoded() -> [Pair]? {
        var pairs = [
            Pair(key: .id, value: id),
            Pair(key: .platform, value: platform),
            Pair(key: .model, value: model),
            Pair(key: .locale, value: locale),
            Pair(key: .accounts, value: accounts)
        ]
        
        if let pushToken = pushToken {
            pairs.append(Pair(key: .pushToken, value: pushToken))
        }
        
        return pairs
    }
}
