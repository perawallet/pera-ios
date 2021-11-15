// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  AssetDetail.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class AssetDetailResponse: ALGResponseModel {
    var debugData: Data?
    
    let assetDetail: AssetDetail
    let currentRound: UInt64

    init(_ apiModel: APIModel = APIModel()) {
        self.assetDetail = apiModel.asset.unwrap(AssetDetail.init)
        self.currentRound = apiModel.currentRound
    }
}

extension AssetDetailResponse {
    struct APIModel: ALGAPIModel {
        let asset: AssetDetail.APIModel
        let currentRound: UInt64

        init() {
            self.asset = AssetDetail.APIModel()
            self.currentRound = 0
        }
    }
}

final class AssetDetail: ALGResponseModel {
    var debugData: Data?

    let id: Int64
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
    var isDeleted: Bool?
    
    var isVerified: Bool = false
    var isRemoved: Bool = false
    var isRecentlyAdded: Bool = false

    init(_ apiModel: APIModel = APIModel()) {
        self.id = apiModel.index
        self.creator = apiModel.params.creator
        self.total = apiModel.params.total
        self.isDefaultFrozen = apiModel.params.defaultFrozen
        self.unitName = apiModel.params.unitName
        self.assetName = apiModel.params.name
        self.url = apiModel.params.url
        self.managerKey = apiModel.params.manager
        self.reserveAddress = apiModel.params.reserve
        self.freezeAddress = apiModel.params.freeze
        self.clawBackAddress = apiModel.params.clawback
        self.fractionDecimals = apiModel.params.decimals
        self.isDeleted = apiModel.params.deleted
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
    struct APIModel: ALGAPIModel {
        let index: Int64
        let params: ParamsAPIModel

        init() {
            self.index = -1
            self.params = ParamsAPIModel()
        }
    }

    struct ParamsAPIModel: ALGAPIModel {
        let creator: String
        let total: UInt64
        let defaultFrozen: Bool?
        let unitName: String?
        let name: String?
        let url: String?
        let manager: String?
        let reserve: String?
        let freeze: String?
        let clawback: String?
        let decimals: Int
        let deleted: Bool?

        init() {
            self.creator = ""
            self.total = 0
            self.defaultFrozen = nil
            self.unitName = nil
            self.name = nil
            self.url = nil
            self.manager = nil
            self.reserve = nil
            self.freeze = nil
            self.clawback = nil
            self.decimals = 0
            self.deleted = nil
        }
    }
}

extension AssetDetail {
    func getDisplayNames() -> (String, String?) {
        if let name = assetName, !name.isEmptyOrBlank,
            let code = unitName, !code.isEmptyOrBlank {
            return (name, "\(code.uppercased())")
        } else if let name = assetName, !name.isEmptyOrBlank {
            return (name, nil)
        } else if let code = unitName, !code.isEmptyOrBlank {
            return ("\(code.uppercased())", nil)
        } else {
            return ("title-unknown".localized, nil)
        }
    }
    
    func hasOnlyAssetName() -> Bool {
        return !assetName.isNilOrEmpty && unitName.isNilOrEmpty
    }
    
    func hasOnlyUnitName() -> Bool {
        return assetName.isNilOrEmpty && !unitName.isNilOrEmpty
    }
    
    func hasBothDisplayName() -> Bool {
        return !assetName.isNilOrEmpty && !unitName.isNilOrEmpty
    }
    
    func hasDisplayName() -> Bool {
        return !assetName.isNilOrEmpty || !unitName.isNilOrEmpty
    }
    
    func hasNoDisplayName() -> Bool {
        return assetName.isNilOrEmpty && unitName.isNilOrEmpty
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
        let lhsId = lhs.id
        let rhsId = rhs.id
        
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
        return lhs.id < rhs.id
    }
}

extension AssetDetail: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}
