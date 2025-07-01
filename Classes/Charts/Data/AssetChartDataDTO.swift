// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AssetChartDataDTO.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class AssetChartDataResultDTO: ALGEntityModel {
    let results: [AssetChartDataDTO]
    
    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.results = apiModel.results
    }
    
    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.results = results
        return apiModel
    }
}

extension AssetChartDataResultDTO {
    struct APIModel: ALGAPIModel {
        var results: [AssetChartDataDTO]

        init() {
            self.results = []
        }
    }
}

final class AssetChartDataDTO: ALGEntityModel, Codable, Equatable, Hashable {
    
    let datetime: String
    let usdValue: Double
    let amount: Double

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.datetime = apiModel.datetime
        self.usdValue = apiModel.usdValue
        self.amount = apiModel.amount
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.datetime = datetime
        apiModel.usdValue = usdValue
        apiModel.amount = amount
        return apiModel
    }
    
    static func == (lhs: AssetChartDataDTO, rhs: AssetChartDataDTO) -> Bool {
        return lhs.datetime == rhs.datetime && lhs.usdValue == rhs.usdValue && lhs.amount == rhs.amount
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(datetime)
        hasher.combine(usdValue)
        hasher.combine(amount)
    }
    
    private enum CodingKeys: String, CodingKey {
        case datetime
        case usdValue = "usd_value"
        case amount
    }
}

extension AssetChartDataDTO {
    struct APIModel: ALGAPIModel {
        var datetime: String
        var usdValue: Double
        var amount: Double

        init() {
            self.datetime = .empty
            self.usdValue = 0
            self.amount = 0
        }
    }
}
