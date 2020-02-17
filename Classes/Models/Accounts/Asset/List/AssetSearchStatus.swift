//
//  AssetSearchStatus.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 17.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct AssetSearchStatus: OptionSet {
    let rawValue: Int
        
    static let verified = AssetSearchStatus(rawValue: 1 << 0)
    static let unverified = AssetSearchStatus(rawValue: 1 << 1)
    static let all: AssetSearchStatus = [.verified, .unverified]
    
    var stringValue: String? {
        if self == .verified {
            return "verified"
        } else if self == .unverified {
            return "unverified"
        } else {
            return nil
        }
    }
    
    func canToggle(for status: AssetSearchStatus) -> Bool {
        return subtracting(status) != []
    }
    
    mutating func toggle(for status: AssetSearchStatus) {
        if self == .all {
            subtract(status)
        } else if self != status {
            formUnion(status)
        }
    }
}
