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

//   ChartDataDTO.swift

import Foundation
import MagpieCore
import MacaroonUtils

public final class ChartDataResultDTO: ALGEntityModel {
    public let results: [ChartDataDTO]
    
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

extension ChartDataResultDTO {
    public struct APIModel: ALGAPIModel {
        var results: [ChartDataDTO]

        public init() {
            self.results = []
        }
    }
}

public final class ChartDataDTO: ALGEntityModel, Codable, Equatable, Hashable {
    
    public let datetime: String
    public let usdValue: String
    public let algoValue: String
    public let valueInCurrency: String
    public let round: Int

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.datetime = apiModel.datetime
        self.usdValue = apiModel.usdValue
        self.algoValue = apiModel.algoValue
        self.valueInCurrency = apiModel.valueInCurrency
        self.round = apiModel.round
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.datetime = datetime
        apiModel.usdValue = usdValue
        apiModel.algoValue = algoValue
        apiModel.valueInCurrency = valueInCurrency
        apiModel.round = round
        return apiModel
    }
    
    public static func == (lhs: ChartDataDTO, rhs: ChartDataDTO) -> Bool {
        return lhs.datetime == rhs.datetime && lhs.usdValue == rhs.usdValue && lhs.algoValue == rhs.algoValue && lhs.valueInCurrency == rhs.valueInCurrency && lhs.round == rhs.round
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(datetime)
        hasher.combine(usdValue)
        hasher.combine(algoValue)
        hasher.combine(valueInCurrency)
        hasher.combine(round)
    }
    
    private enum CodingKeys: String, CodingKey {
        case datetime
        case usdValue = "usd_value"
        case algoValue = "algo_value"
        case valueInCurrency = "value_in_currency"
        case round
    }
}

extension ChartDataDTO {
    public struct APIModel: ALGAPIModel {
        var datetime: String
        var usdValue: String
        var algoValue: String
        var valueInCurrency: String
        var round: Int

        public init() {
            self.datetime = .empty
            self.usdValue = .empty
            self.algoValue = .empty
            self.valueInCurrency = .empty
            self.round = 0
        }
    }
}
