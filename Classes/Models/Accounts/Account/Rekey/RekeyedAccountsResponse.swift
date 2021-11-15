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
//  RekeyedAccountsResponse.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class RekeyedAccountsResponse: ALGResponseModel {
    var debugData: Data?

    let accounts: [Account]
    let currentRound: UInt64
    let nextToken: String?

    init(_ apiModel: APIModel = APIModel()) {
        self.accounts = apiModel.accounts.unwrapMap(Account.init)
        self.currentRound = apiModel.currentRound
        self.nextToken = apiModel.nextToken
    }
}

extension RekeyedAccountsResponse {
    struct APIModel: ALGAPIModel {
        let accounts: [Account.APIModel]?
        let currentRound: UInt64
        let nextToken: String?

        init() {
            self.accounts = []
            self.currentRound = 123456
            self.nextToken = nil
        }
    }
}
