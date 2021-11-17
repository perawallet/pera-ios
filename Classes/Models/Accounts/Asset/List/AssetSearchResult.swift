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
//  AssetQueryItem.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class AssetSearchResult: ALGEntityModel {
    let id: Int64
    let name: String?
    let unitName: String?
    let isVerified: Bool

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.id = apiModel.assetId
        self.name = apiModel.name
        self.unitName = apiModel.unitName
        self.isVerified = apiModel.isVerified ?? false
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.assetId = id
        apiModel.name = name
        apiModel.unitName = unitName
        apiModel.isVerified = isVerified
        return apiModel
    }
}

extension AssetSearchResult {
    struct APIModel: ALGAPIModel {
        var assetId: Int64
        var name: String?
        var unitName: String?
        var isVerified: Bool?

        init() {
            self.assetId = 0
            self.name = nil
            self.unitName = nil
            self.isVerified = nil
        }
    }
}

/// <todo>
/// Rethink the paginated list model. Should be more reusable.
final class AssetSearchResultList:
    PaginatedList<AssetSearchResult>,
    ALGEntityModel {
    convenience init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.init(
            pagination: apiModel,
            results: apiModel.results.unwrapMap(AssetSearchResult.init)
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

extension AssetSearchResultList {
    struct APIModel:
        ALGAPIModel,
        PaginationComponents {
        var count: Int?
        var next: URL?
        var previous: String?
        var results: [AssetSearchResult.APIModel]?

        init() {
            self.count = nil
            self.next = nil
            self.previous = nil
            self.results = []
        }
    }
}
