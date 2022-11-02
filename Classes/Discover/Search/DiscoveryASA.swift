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

//   DiscoveryASA.swift

import Foundation
import MacaroonUtils
import MagpieCore

final class DiscoveryASA: ALGEntityModel {
    let type: String
    let id: AssetID
    let name: String
    let logo: URL?
    let verificationTier: AssetVerificationTier
    let unitName: String?
    let collectible: DiscoveryASACollectible?
    let usdValue: String?

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.type = apiModel.type
        self.id = apiModel.id
        self.name = apiModel.name
        self.logo = apiModel.logo
        self.verificationTier = apiModel.verificationTier
        self.unitName = apiModel.unitName
        self.collectible = apiModel.collectible.unwrap({DiscoveryASACollectible($0)})
        self.usdValue = apiModel.usdValue
    }

    init() {
        type = "asset"
        id = 0
        name = ""
        logo = nil
        verificationTier = .init()
        unitName = nil
        collectible = .init()
        usdValue = nil
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.type = type
        apiModel.id = id
        apiModel.name = name
        apiModel.logo = logo
        apiModel.verificationTier = verificationTier
        apiModel.unitName = unitName
        apiModel.collectible = collectible?.encode()
        apiModel.usdValue = usdValue.unwrap { String(describing: $0) }
        return apiModel
    }
}

final class DiscoveryASACollectible: ALGEntityModel {
    let title: String
    let primaryImage: URL?

    init(_ apiModel: APIModel) {
        self.title = apiModel.title
        self.primaryImage = apiModel.primaryImage
    }

    init() {
        title = ""
        primaryImage = nil
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.title = title
        apiModel.primaryImage = primaryImage
        return apiModel
    }
}

/// <todo>
/// Rethink the paginated list model. Should be more reusable.
final class DiscoveryASAPaginatedList:
    PaginatedList<DiscoveryASA>,
    ALGEntityModel {
    convenience init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.init(
            pagination: apiModel,
            results: apiModel.results.unwrapMap(DiscoveryASA.init)
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

extension DiscoveryASAPaginatedList {
    struct APIModel:
        ALGAPIModel,
        PaginationComponents {
        var count: Int?
        var next: URL?
        var previous: String?
        var results: [DiscoveryASA.APIModel]?

        init() {
            self.count = nil
            self.next = nil
            self.previous = nil
            self.results = []
        }
    }
}

extension DiscoveryASA {
    struct APIModel: ALGAPIModel {
        var type: String
        var id: AssetID
        var name: String
        var logo: URL?
        var verificationTier: AssetVerificationTier
        var unitName: String?
        var collectible: DiscoveryASACollectible.APIModel?
        var usdValue: String?

        init() {
            type = "asset"
            id = -1
            name = ""
            logo = nil
            verificationTier = .init()
            unitName = nil
            collectible = nil
            usdValue = nil
        }

        private enum CodingKeys: String, CodingKey {
            case type
            case id = "asset_id"
            case name
            case logo
            case verificationTier = "verification_tier"
            case unitName = "unit_name"
            case collectible
            case usdValue = "usd_value"
        }
    }
}

extension DiscoveryASACollectible {
    struct APIModel: ALGAPIModel {
        var title: String
        var primaryImage: URL?

        init() {
            title = ""
            primaryImage = nil
        }

        private enum CodingKeys: String, CodingKey {
            case title
            case primaryImage = "primary_image"
        }
    }
}
