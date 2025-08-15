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

//   SwapTransactionGroup.swift

import Foundation
import MacaroonUtils

public final class SwapTransactionGroup:
    ALGEntityModel,
    Equatable {
    public let purpose: SwapTransactionPurpose
    public let groupID: String
    public let transactions: [Data]?
    public var signedTransactions: [Data?]?

    public var transactionsToSign: [Data?] {
        guard let signedTransactions else {
            return []
        }

        return signedTransactions.filter { $0.isNilOrEmpty }
    }

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.purpose = apiModel.purpose ?? .init()
        self.groupID = apiModel.transactionGroupID ?? ""
        self.transactions = apiModel.transactions
        self.signedTransactions = apiModel.signedTransactions
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.purpose = purpose
        apiModel.transactionGroupID = groupID
        apiModel.transactions = transactions
        apiModel.signedTransactions = signedTransactions
        return apiModel
    }

    public static func == (
        lhs: SwapTransactionGroup,
        rhs: SwapTransactionGroup
    ) -> Bool {
        return
            lhs.purpose == rhs.purpose &&
            lhs.groupID == rhs.groupID &&
            lhs.transactions == rhs.transactions &&
            lhs.signedTransactions == rhs.signedTransactions
    }
}

extension SwapTransactionGroup {
    public struct APIModel: ALGAPIModel {
        public var purpose: SwapTransactionPurpose?
        public var transactionGroupID: String?
        public var transactions: [Data]?
        public var signedTransactions: [Data?]?

        private enum CodingKeys:
            String,
            CodingKey {
            case purpose
            case transactionGroupID = "transaction_group_id"
            case transactions
            case signedTransactions = "signed_transactions"
        }
        
        public init() {}
    }
}
