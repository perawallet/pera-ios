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

//  Account+FastLookup.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class AccountFastLookup: ALGEntityModel {
    let algoValue: String
    let usdValue: String
    let calculationType: String
    let accountExists: Bool

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.algoValue = apiModel.algoValue
        self.usdValue = apiModel.usdValue
        self.calculationType = apiModel.calculationType
        self.accountExists = apiModel.accountExists
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.algoValue = algoValue
        apiModel.usdValue = usdValue
        apiModel.calculationType = calculationType
        apiModel.accountExists = accountExists
        return apiModel
    }
}

extension AccountFastLookup {
    struct APIModel: ALGAPIModel {
        var algoValue: String
        var usdValue: String
        var calculationType: String
        var accountExists: Bool

        init() {
            self.algoValue = .empty
            self.usdValue = .empty
            self.calculationType = .empty
            self.accountExists = false
        }

        private enum CodingKeys: String, CodingKey {
            case algoValue = "algo_value"
            case usdValue = "usd_value"
            case calculationType = "calculation_type"
            case accountExists = "account_exists"
        }
    }
}
