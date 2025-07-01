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

//   HomeChartDataDTO.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class HomeChartDataResultDTO: ALGEntityModel {
    let results: [HomeChartDataDTO]
    
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

extension HomeChartDataResultDTO {
    struct APIModel: ALGAPIModel {
        var results: [HomeChartDataDTO]

        init() {
            self.results = []
        }
    }
}

final class HomeChartDataDTO: ALGEntityModel, Codable, Equatable, Hashable {
    
    let datetime: String
    let usdValue: String
    let algoValue: String
    let round: Int

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.datetime = apiModel.datetime
        self.usdValue = apiModel.usdValue
        self.algoValue = apiModel.algoValue
        self.round = apiModel.round
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.datetime = datetime
        apiModel.usdValue = usdValue
        apiModel.algoValue = algoValue
        apiModel.round = round
        return apiModel
    }
    
    static func == (lhs: HomeChartDataDTO, rhs: HomeChartDataDTO) -> Bool {
        return lhs.datetime == rhs.datetime && lhs.usdValue == rhs.usdValue && lhs.algoValue == rhs.algoValue && lhs.round == rhs.round
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(datetime)
        hasher.combine(usdValue)
        hasher.combine(algoValue)
        hasher.combine(round)
    }
    
    private enum CodingKeys: String, CodingKey {
        case datetime
        case usdValue = "usd_value"
        case algoValue = "algo_value"
        case round
    }
}

extension HomeChartDataDTO {
    struct APIModel: ALGAPIModel {
        var datetime: String
        var usdValue: String
        var algoValue: String
        var round: Int

        init() {
            self.datetime = .empty
            self.usdValue = .empty
            self.algoValue = .empty
            self.round = 0
        }
    }
}
