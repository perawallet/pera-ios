//
//  AssetDetail.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class AssetDetail: Model {
    let creator: String
    let total: UInt64
    let isDefaultFrozen: Bool?
    let unitName: String?
    let assetName: String?
    let url: String?
    let managerKey: String?
    let reserveAddress: String?
    let freezeAddress: String?
    let clawBackAddress: String?
    
    var index: String?
}

extension AssetDetail {
    enum CodingKeys: String, CodingKey {
        case creator = "creator"
        case total = "total"
        case isDefaultFrozen = "defaultfrozen"
        case unitName = "unitname"
        case assetName = "assetname"
        case url = "url"
        case managerKey = "managerkey"
        case reserveAddress = "reserveaddr"
        case freezeAddress = "freezeaddr"
        case clawBackAddress = "clawbackaddr"
        case index = "index"
    }
}

extension AssetDetail {
    func assetDisplayName() -> NSAttributedString? {
        guard let name = assetName,
            let code = unitName else {
                return nil
        }
        
        let nameText = name.attributed([.textColor(SharedColors.black), .font(UIFont.font(.overpass, withWeight: .semiBold(size: 13.0)))])
        let codeText = " (\(code))".attributed([
            .textColor(SharedColors.purple),
            .font(UIFont.font(.overpass, withWeight: .semiBold(size: 13.0)))
        ])
        return nameText + codeText
    }
}

extension AssetDetail: Encodable {
}

extension AssetDetail: Comparable {
    static func == (lhs: AssetDetail, rhs: AssetDetail) -> Bool {
        guard let lhsIndex = lhs.index,
            let rhsIndex = rhs.index else {
                return false
        }
        return lhsIndex == rhsIndex
    }
    
    static func < (lhs: AssetDetail, rhs: AssetDetail) -> Bool {
        guard let lhsIndex = lhs.index,
            let rhsIndex = rhs.index,
            let lhsIntValue = Int(lhsIndex),
            let rhsIntValue = Int(rhsIndex) else {
                return false
        }
        return lhsIntValue < rhsIntValue
    }
}
