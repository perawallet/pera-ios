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

public final class AssetChartDataResultDTO: ALGEntityModel {
    public let results: [AssetChartDataDTO]
    
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

extension AssetChartDataResultDTO {
    public struct APIModel: ALGAPIModel {
        var results: [AssetChartDataDTO]

        public init() {
            self.results = []
        }
    }
}

public final class AssetChartDataDTO: ALGEntityModel, Codable {
    public let datetime: String
    public let usdValue: String
    public let amount: String
    public let valueInCurrency: String

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.datetime = apiModel.datetime
        self.usdValue = apiModel.usdValue
        self.amount = apiModel.amount
        self.valueInCurrency = apiModel.valueInCurrency
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.datetime = datetime
        apiModel.usdValue = usdValue
        apiModel.amount = amount
        apiModel.valueInCurrency = valueInCurrency
        return apiModel
    }
    
    private enum CodingKeys: String, CodingKey {
        case datetime
        case usdValue = "usd_value"
        case amount
        case valueInCurrency = "value_in_currency"
    }
}

extension AssetChartDataDTO {
    public struct APIModel: ALGAPIModel {
        var datetime: String
        var usdValue: String
        var amount: String
        var valueInCurrency: String

        public init() {
            self.datetime = .empty
            self.usdValue = .empty
            self.amount = .empty
            self.valueInCurrency = .empty
        }
    }
}

extension AssetChartDataDTO: Equatable {
    public static func == (lhs: AssetChartDataDTO, rhs: AssetChartDataDTO) -> Bool {
        lhs.datetime == rhs.datetime && lhs.usdValue == rhs.usdValue && lhs.amount == rhs.amount && lhs.valueInCurrency == rhs.valueInCurrency
    }
}

extension AssetChartDataDTO: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(datetime)
        hasher.combine(usdValue)
        hasher.combine(amount)
        hasher.combine(valueInCurrency)
    }
}
