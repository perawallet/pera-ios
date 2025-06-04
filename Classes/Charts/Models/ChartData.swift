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

//   ChartData.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class ChartDataResult: ALGEntityModel {
    let results: [ChartData]
    
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

extension ChartDataResult {
    struct APIModel: ALGAPIModel {
        var results: [ChartData]

        init() {
            self.results = []
        }
    }
}

final class ChartData: ALGEntityModel, Codable, Equatable, Hashable {
    
    let datetime: String
    let usd_value: String
    let algo_value: String
    let round: Int

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.datetime = apiModel.datetime
        self.usd_value = apiModel.usd_value
        self.algo_value = apiModel.algo_value
        self.round = apiModel.round
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.datetime = datetime
        apiModel.usd_value = usd_value
        apiModel.algo_value = algo_value
        apiModel.round = round
        return apiModel
    }
    
    static func == (lhs: ChartData, rhs: ChartData) -> Bool {
        return lhs.datetime == rhs.datetime && lhs.usd_value == rhs.usd_value && lhs.algo_value == rhs.algo_value && lhs.round == rhs.round
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(datetime)
        hasher.combine(usd_value)
        hasher.combine(algo_value)
        hasher.combine(round)
    }
}

extension ChartData {
    struct APIModel: ALGAPIModel {
        var datetime: String
        var usd_value: String
        var algo_value: String
        var round: Int

        init() {
            self.datetime = .empty
            self.usd_value = .empty
            self.algo_value = .empty
            self.round = 0
        }
    }
}
