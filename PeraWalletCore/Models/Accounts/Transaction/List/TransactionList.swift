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
//  TransactionList.swift

import Foundation
import MagpieCore
import MacaroonUtils

public final class TransactionList: ALGEntityModel {
    public let currentRound: UInt64
    public let nextToken: String?
    public let transactions: [Transaction]

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.currentRound = apiModel.currentRound ?? 0
        self.nextToken = apiModel.nextToken
        self.transactions = apiModel.transactions.unwrapMap(Transaction.init)
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.currentRound = currentRound
        apiModel.nextToken = nextToken
        apiModel.transactions = transactions.map { $0.encode() }
        return apiModel
    }
}

extension TransactionList {
    public struct APIModel: ALGAPIModel {
        var currentRound: UInt64?
        var nextToken: String?
        var transactions: [Transaction.APIModel]?

        public init() {
            self.currentRound = nil
            self.nextToken = nil
            self.transactions = nil
        }

        private enum CodingKeys: String, CodingKey {
            case currentRound = "current-round"
            case nextToken = "next-token"
            case transactions
        }
    }
}
