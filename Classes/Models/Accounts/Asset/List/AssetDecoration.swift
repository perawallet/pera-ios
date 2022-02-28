// Copyright 2022 Pera Wallet, LDA

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
//  AssetDecoration.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class AssetDecoration: ALGEntityModel {
    let id: Int64
    let name: String?
    let unitName: String?
    let decimals: Int
    let usdValue: Decimal?
    let isVerified: Bool
    let creator: AssetCreator?
    let collectible: Collectible?

    var isRemoved = false
    var isRecentlyAdded = false

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.id = apiModel.assetId
        self.name = apiModel.name
        self.unitName = apiModel.unitName
        self.decimals = apiModel.fractionDecimals ?? 0
        self.usdValue = apiModel.usdValue.unwrap { Decimal(string: $0) }
        self.isVerified = apiModel.isVerified ?? false
        self.creator = apiModel.creator.unwrap(AssetCreator.init)
        self.collectible = apiModel.collectible.unwrap(Collectible.init)
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.assetId = id
        apiModel.name = name
        apiModel.unitName = unitName
        apiModel.fractionDecimals = decimals
        apiModel.usdValue = usdValue.unwrap { String(describing: $0) }
        apiModel.isVerified = isVerified
        apiModel.creator = creator?.encode()
        apiModel.collectible = collectible?.encode()
        return apiModel
    }

    init(standardAsset: StandardAsset) {
        self.id = standardAsset.id
        self.name = standardAsset.name
        self.unitName = standardAsset.unitName
        self.decimals = standardAsset.decimals
        self.usdValue = standardAsset.usdValue
        self.isVerified = standardAsset.isVerified
        self.creator = standardAsset.creator
        self.collectible = nil
    }

    var isCollectible: Bool {
        return collectible != nil
    }
}

extension AssetDecoration {
    struct APIModel: ALGAPIModel {
        var assetId: Int64
        var name: String?
        var unitName: String?
        var fractionDecimals: Int?
        var usdValue: String?
        var isVerified: Bool?
        var creator: AssetCreator.APIModel?
        var collectible: Collectible.APIModel?

        init() {
            self.assetId = 0
            self.name = nil
            self.unitName = nil
            self.fractionDecimals = nil
            self.usdValue = nil
            self.isVerified = nil
            self.creator = nil
            self.collectible = nil
        }

        private enum CodingKeys: String, CodingKey {
            case assetId = "asset_id"
            case name
            case unitName = "unit_name"
            case fractionDecimals = "fraction_decimals"
            case usdValue = "usd_value"
            case isVerified = "is_verified"
            case creator
            case collectible
        }
    }
}

extension AssetDecoration {
    func hasDisplayName() -> Bool {
        return !name.isNilOrEmpty || !unitName.isNilOrEmpty
    }

    func getDisplayNames() -> (String, String?) {
        if let name = name, !name.isEmptyOrBlank,
            let code = unitName, !code.isEmptyOrBlank {
            return (name, "\(code.uppercased())")
        } else if let name = name, !name.isEmptyOrBlank {
            return (name, nil)
        } else if let code = unitName, !code.isEmptyOrBlank {
            return ("\(code.uppercased())", nil)
        } else {
            return ("title-unknown".localized, nil)
        }
    }

    var assetNameRepresentation: String {
        if let name = name, !name.isEmptyOrBlank {
            return name
        }
        return "title-unknown".localized
    }

    var unitNameRepresentation: String {
        if let code = unitName, !code.isEmptyOrBlank {
            return code.uppercased()
        }
        return "title-unknown".localized
    }
}

extension AssetDecoration: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}

extension AssetDecoration: Comparable {
    static func == (lhs: AssetDecoration, rhs: AssetDecoration) -> Bool {
        return lhs.id == rhs.id &&
            lhs.decimals == rhs.decimals &&
            lhs.isVerified == rhs.isVerified &&
            lhs.name == rhs.name &&
            lhs.unitName == rhs.unitName
    }

    static func < (lhs: AssetDecoration, rhs: AssetDecoration) -> Bool {
        return lhs.id < rhs.id
    }
}

/// <todo>
/// Rethink the paginated list model. Should be more reusable.
final class AssetDecorationList:
    PaginatedList<AssetDecoration>,
    ALGEntityModel {
    convenience init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.init(
            pagination: apiModel,
            results: apiModel.results.unwrapMap(AssetDecoration.init)
        )
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.count = count
        apiModel.next = next
        apiModel.previous = previous
        apiModel.results = results.map { $0.encode() }
        return apiModel
    }
}

extension AssetDecorationList {
    struct APIModel:
        ALGAPIModel,
        PaginationComponents {
        var count: Int?
        var next: URL?
        var previous: String?
        var results: [AssetDecoration.APIModel]?

        init() {
            self.count = nil
            self.next = nil
            self.previous = nil
            self.results = []
        }
    }
}

typealias AssetID = Int64
