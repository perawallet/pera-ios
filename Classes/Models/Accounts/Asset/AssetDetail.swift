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
    let fractionDecimals: Int
    
    var index: String?
    var isRemoved: Bool = false
    var isRecentlyAdded: Bool = false
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        creator = try container.decode(String.self, forKey: .creator)
        total = try container.decode(UInt64.self, forKey: .total)
        isDefaultFrozen = try container.decodeIfPresent(Bool.self, forKey: .isDefaultFrozen)
        unitName = try container.decodeIfPresent(String.self, forKey: .unitName)
        assetName = try container.decodeIfPresent(String.self, forKey: .assetName)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        managerKey = try container.decodeIfPresent(String.self, forKey: .managerKey)
        reserveAddress = try? container.decodeIfPresent(String.self, forKey: .reserveAddress)
        freezeAddress = try? container.decodeIfPresent(String.self, forKey: .freezeAddress)
        clawBackAddress = try container.decodeIfPresent(String.self, forKey: .clawBackAddress)
        fractionDecimals = try container.decodeIfPresent(Int.self, forKey: .fractionDecimals) ?? 0
        
        index = try? container.decodeIfPresent(String.self, forKey: .index)
        isRemoved = try container.decodeIfPresent(Bool.self, forKey: .isRemoved) ?? false
        isRecentlyAdded = try container.decodeIfPresent(Bool.self, forKey: .isRecentlyAdded) ?? false
    }
}

extension AssetDetail {
    private enum CodingKeys: String, CodingKey {
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
        case isRemoved = "isRemoved"
        case isRecentlyAdded = "isRecentlyAdded"
        case fractionDecimals = "decimals"
    }
}

extension AssetDetail {
    func assetDisplayName(
        with font: UIFont = UIFont.font(.overpass, withWeight: .semiBold(size: 13.0)),
        isIndexIncluded: Bool = true,
        shouldDisplayIndexWithName: Bool = true
    ) -> NSAttributedString? {
        guard let index = index else {
            return nil
        }
        
        if let name = assetName, !name.isEmptyOrBlank,
            let code = unitName, !code.isEmptyOrBlank {
            let nameText = name.attributed([.textColor(SharedColors.black), .font(font)])
            let codeText = " (\(code))".attributed([.textColor(SharedColors.purple), .font(font)])
            
            if shouldDisplayIndexWithName {
                let indexText = " \(index)".attributed([.textColor(SharedColors.darkGray), .font(font)])
                return nameText + codeText + indexText
            }
            
            return nameText + codeText
        } else if let name = assetName, !name.isEmptyOrBlank {
            if shouldDisplayIndexWithName {
                let indexText = " \(index)".attributed([.textColor(SharedColors.darkGray), .font(font)])
                return name.attributed([.textColor(SharedColors.black), .font(font)]) + indexText
            }
            return name.attributed([.textColor(SharedColors.black), .font(font)])
        } else if let code = unitName, !code.isEmptyOrBlank {
            if shouldDisplayIndexWithName {
                let indexText = " \(index)".attributed([.textColor(SharedColors.darkGray), .font(font)])
                return "(\(code))".attributed([.textColor(SharedColors.purple), .font(font)]) + indexText
            }
            return "(\(code))".attributed([.textColor(SharedColors.purple), .font(font)])
        } else {
            let unknownText = "title-unknown".localized.attributed([
                .textColor(SharedColors.orange),
                 .font(UIFont.font(.avenir, withWeight: .demiBoldItalic(size: 13.0)))
            ])
            if !isIndexIncluded {
                return unknownText
            }
            
            let indexText = index.attributed([
                .textColor(SharedColors.black),
                .font(UIFont.font(.avenir, withWeight: .demiBold(size: 13.0)))
            ])
            
            return unknownText + " ".attributed() + indexText
        }
    }
    
    func getDisplayNames(isDisplayingBrackets: Bool = true) -> (String, String?) {
        if let name = assetName, !name.isEmptyOrBlank,
            let code = unitName, !code.isEmptyOrBlank {
            if isDisplayingBrackets {
                return (name, "(\(code))")
            }
            return (name, "\(code)")
        } else if let name = assetName, !name.isEmptyOrBlank {
            return (name, nil)
        } else if let code = unitName, !code.isEmptyOrBlank {
            if isDisplayingBrackets {
                return ("(\(code))", nil)
            }
            return ("\(code)", nil)
        } else {
            return ("title-unknown".localized, nil)
        }
    }
    
    func hasDisplayName() -> Bool {
        return !assetName.isNilOrEmpty || !unitName.isNilOrEmpty
    }
    
    func getAssetName() -> String {
        if let name = assetName, !name.isEmptyOrBlank {
            return name
        }
        return "title-unknown".localized
    }
    
    func getAssetCode() -> String {
        if let code = unitName, !code.isEmptyOrBlank {
            return code
        }
        return "title-unknown".localized
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
        
        if lhsIndex == rhsIndex && lhs.assetName != rhs.assetName {
            return false
        } else if lhsIndex == rhsIndex && lhs.unitName != rhs.unitName {
            return false
        } else {
            return lhsIndex == rhsIndex
        }
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
