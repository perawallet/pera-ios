//
//  DeviceRegistrationDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 4.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct DeviceRegistrationDraft: JSONBody {
    typealias Key = RequestParameter
    
    let pushToken: String?
    let platform = "ios"
    let model = UIDevice.current.model
    let locale = Locale.current.languageCode ?? "en"
    var accounts: [String] = []
    
    func decoded() -> [Pair]? {
        var pairs = [
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

struct DeviceDeletionDraft: JSONBody {
    typealias Key = RequestParameter
    
    let pushToken: String
    
    func decoded() -> [Pair]? {
        return [
            Pair(key: .pushToken, value: pushToken)
        ]
    }
}
