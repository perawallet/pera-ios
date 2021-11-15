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

final class AssetSearchResult: ALGResponseModel {
    var debugData: Data?
    
    let id: Int64
    let name: String?
    let unitName: String?
    let isVerified: Bool

    init(_ apiModel: APIModel = APIModel()) {
        self.id = apiModel.assetId
        self.name = apiModel.name
        self.unitName = apiModel.unitName
        self.isVerified = apiModel.isVerified
    }
}

extension AssetSearchResult {
    struct APIModel: ALGAPIModel {
        let assetId: Int64
        let name: String?
        let unitName: String?
        let isVerified: Bool

        init() {
            self.assetId = 0
            self.name = nil
            self.unitName = nil
            self.isVerified = false
        }
    }
}

final class AssetSearchResultList: PaginatedList<AssetSearchResult>, ALGResponseModel {
    var debugData: Data?

    convenience init(_ apiModel: APIModel = APIModel()){
        self.init(pagination: apiModel, results: apiModel.results.unwrapMap(AssetSearchResult.init))
    }
}

extension AssetSearchResultList {
    struct APIModel: ALGAPIModel, PaginationComponents {
        let count: Int?
        let next: URL?
        let previous: String?
        let results: [AssetSearchResult.APIModel]?

        init() {
            self.count = nil
            self.next = nil
            self.previous = nil
            self.results = []
        }
    }
}
