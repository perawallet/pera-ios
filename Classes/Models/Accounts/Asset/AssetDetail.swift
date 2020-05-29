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
    
    var id: Int64?
    var isVerified: Bool = false
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
        
        id = try? container.decodeIfPresent(Int64.self, forKey: .id)
        isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified) ?? false
        isRemoved = try container.decodeIfPresent(Bool.self, forKey: .isRemoved) ?? false
        isRecentlyAdded = try container.decodeIfPresent(Bool.self, forKey: .isRecentlyAdded) ?? false
    }
    
    init(searchResult: AssetSearchResult) {
        self.id = searchResult.id
        self.assetName = searchResult.name
        self.unitName = searchResult.unitName
        self.isVerified = searchResult.isVerified
        
        self.fractionDecimals = 0
        self.total = 0
        self.creator = ""
        
        isDefaultFrozen = nil
        url = nil
        managerKey = nil
        reserveAddress = nil
        freezeAddress = nil
        clawBackAddress = nil
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
        case id = "index"
        case isRemoved = "isRemoved"
        case isRecentlyAdded = "isRecentlyAdded"
        case isVerified = "is_verified"
        case fractionDecimals = "decimals"
    }
}

extension AssetDetail {
    func assetDisplayName(
        with font: UIFont = UIFont.font(withWeight: .medium(size: 14.0)),
        isIndexIncluded: Bool = true,
        shouldDisplayIndexWithName: Bool = true
    ) -> NSAttributedString? {
        guard let id = id else {
            return nil
        }
        
        if let name = assetName, !name.isEmptyOrBlank,
            let code = unitName, !code.isEmptyOrBlank {
            let nameText = name.attributed([.textColor(SharedColors.primaryText), .font(font)])
            let codeText = " (\(code.uppercased()))".attributed([.textColor(SharedColors.detailText), .font(font)])
            
            if shouldDisplayIndexWithName {
                let indexText = " \(id)".attributed([.textColor(SharedColors.detailText), .font(font)])
                return nameText + codeText + indexText
            }
            
            return nameText + codeText
        } else if let name = assetName, !name.isEmptyOrBlank {
            if shouldDisplayIndexWithName {
                let indexText = " \(id)".attributed([.textColor(SharedColors.detailText), .font(font)])
                return name.attributed([.textColor(SharedColors.primaryText), .font(font)]) + indexText
            }
            return name.attributed([.textColor(SharedColors.primaryText), .font(font)])
        } else if let code = unitName, !code.isEmptyOrBlank {
            if shouldDisplayIndexWithName {
                let indexText = " \(id)".attributed([.textColor(SharedColors.detailText), .font(font)])
                return "(\(code.uppercased()))".attributed([.textColor(SharedColors.detailText), .font(font)]) + indexText
            }
            return "(\(code.uppercased()))".attributed([.textColor(SharedColors.detailText), .font(font)])
        } else {
            let unknownText = "title-unknown".localized.attributed([
                .textColor(SharedColors.secondary),
                 .font(UIFont.font(withWeight: .boldItalic(size: 14.0)))
            ])
            if !isIndexIncluded {
                return unknownText
            }
            
            let indexText = "\(id)".attributed([
                .textColor(SharedColors.primaryText),
                .font(UIFont.font(withWeight: .medium(size: 14.0)))
            ])
            
            return unknownText + " ".attributed() + indexText
        }
    }
    
    func getDisplayNames(isDisplayingBrackets: Bool = true) -> (String, String?) {
        if let name = assetName, !name.isEmptyOrBlank,
            let code = unitName, !code.isEmptyOrBlank {
            if isDisplayingBrackets {
                return (name, "(\(code.uppercased()))")
            }
            return (name, "\(code)")
        } else if let name = assetName, !name.isEmptyOrBlank {
            return (name, nil)
        } else if let code = unitName, !code.isEmptyOrBlank {
            if isDisplayingBrackets {
                return ("(\(code.uppercased()))", nil)
            }
            return ("\(code.uppercased())", nil)
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
            return code.uppercased()
        }
        return "title-unknown".localized
    }
}

extension AssetDetail: Encodable {
}

extension AssetDetail: Comparable {
    static func == (lhs: AssetDetail, rhs: AssetDetail) -> Bool {
        guard let lhsId = lhs.id,
            let rhsId = rhs.id else {
                return false
        }
        
        if lhsId == rhsId && lhs.fractionDecimals != rhs.fractionDecimals {
            return false
        }
        
        if lhsId == rhsId && lhs.isVerified != rhs.isVerified {
            return false
        }
        
        if lhsId == rhsId && lhs.assetName != rhs.assetName {
            return false
        } else if lhsId == rhsId && lhs.unitName != rhs.unitName {
            return false
        } else {
            return lhsId == rhsId
        }
    }
    
    static func < (lhs: AssetDetail, rhs: AssetDetail) -> Bool {
        guard let lhsId = lhs.id,
            let rhsId = rhs.id else {
                return false
        }
        return lhsId < rhsId
    }
}
