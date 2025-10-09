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

//   SwapTransactionPreparation.swift

import Foundation

public final class SwapTransactionPreparation: ALGEntityModel {
    public let transactionGroups: [SwapTransactionGroup]
    public let swapId: UInt64?
    public let swapVersion: String?

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.transactionGroups = apiModel.transactionGroups.unwrapMap(SwapTransactionGroup.init)
        self.swapId = apiModel.swapId
        self.swapVersion = apiModel.swapVersion
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.transactionGroups = transactionGroups.map { $0.encode() }
        apiModel.swapId = swapId
        apiModel.swapVersion = swapVersion
        return apiModel
    }
}

extension SwapTransactionPreparation {
    public struct APIModel: ALGAPIModel {
        var transactionGroups: [SwapTransactionGroup.APIModel]?
        var swapId: UInt64?
        var swapVersion: String?

        public init() {
            self.transactionGroups = []
            self.swapId = nil
            self.swapVersion = nil
        }

        private enum CodingKeys:
            String,
            CodingKey {
            case transactionGroups =  "transaction_groups"
            case swapId = "swap_id"
            case swapVersion = "swap_version"
        }
    }
}
