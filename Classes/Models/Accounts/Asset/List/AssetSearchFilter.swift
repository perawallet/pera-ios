//
//  AssetSearchFilter.swift

import Foundation

struct AssetSearchFilter: OptionSet {
    let rawValue: Int
        
    static let verified = AssetSearchFilter(rawValue: 1 << 0)
    static let unverified = AssetSearchFilter(rawValue: 1 << 1)
    static let all: AssetSearchFilter = [.verified, .unverified]
    
    var stringValue: String? {
        if self == .verified {
            return "verified"
        }
        
        if self == .unverified {
            return "unverified"
        }
        
        return nil
    }
    
    func canToggle(_ filterOption: AssetSearchFilter) -> Bool {
        return subtracting(filterOption) != []
    }
    
    mutating func toggle(_ filterOption: AssetSearchFilter) {
        if self == .all {
            subtract(filterOption)
        } else if self != filterOption {
            formUnion(filterOption)
        }
    }
}
