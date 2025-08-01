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

//
//  AccountResponse.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class AccountApiResponse: ALGEntityModel {
    let account: Account
    let currentRound: UInt64

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.account = Account(apiModel.account)
        self.currentRound = apiModel.currentRound
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.account = account.encode()
        apiModel.currentRound = currentRound
        return apiModel
    }
}

extension AccountApiResponse {
    struct APIModel: ALGAPIModel {
        var account: Account.APIModel
        var currentRound: UInt64

        init() {
            self.account = Account.APIModel()
            self.currentRound = 1
        }

        private enum CodingKeys: String, CodingKey {
            case account
            case currentRound = "current-round"
        }
    }
}
