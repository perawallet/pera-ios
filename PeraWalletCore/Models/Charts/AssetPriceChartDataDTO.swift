// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AssetPriceChartDataDTO.swift

import Foundation
import MagpieCore
import MacaroonUtils

public final class AssetPriceChartDataResultDTO: ALGEntityModel {
    public let results: [AssetPriceChartItemDTO]
    
    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.results = apiModel.results
    }
    
    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.results = results
        return apiModel
    }
}

extension AssetPriceChartDataResultDTO {
    public struct APIModel: ALGAPIModel, Decodable {
        public var results: [AssetPriceChartItemDTO]

        public init() {
            self.results = []
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.results = try container.decode([AssetPriceChartItemDTO].self)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(results)
        }
    }
}

public final class AssetPriceChartItemDTO: ALGEntityModel, Codable {
    public let datetime: String
    public let price: Double

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.datetime = apiModel.datetime
        self.price = apiModel.price
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.datetime = datetime
        apiModel.price = price
        return apiModel
    }
    
    private enum CodingKeys: String, CodingKey {
        case datetime
        case price
    }
}

extension AssetPriceChartItemDTO {
    public struct APIModel: ALGAPIModel {
        var datetime: String
        var price: Double

        public init() {
            self.datetime = .empty
            self.price = 0.0
        }
    }
}

extension AssetPriceChartItemDTO: Equatable {
    public static func == (lhs: AssetPriceChartItemDTO, rhs: AssetPriceChartItemDTO) -> Bool {
        lhs.datetime == rhs.datetime && lhs.price == rhs.price
    }
}


extension AssetPriceChartItemDTO: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(datetime)
        hasher.combine(price)
    }
}
