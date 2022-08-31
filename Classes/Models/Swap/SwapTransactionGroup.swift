// Copyright 2022 Pera Wallet, LDA

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

final class SwapTransactionGroup: ALGEntityModel {
    let purpose: SwapTransactionPurpose?
    let groupID: Int
    let transactions: [Data]?
    let signedTransactions: [Data?]?

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.purpose = apiModel.purpose
        self.groupID = Int(apiModel.transactionGroupID).unwrap(or: -1)
        self.transactions = apiModel.transactions
        self.signedTransactions = apiModel.signedTransactions
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.purpose = purpose
        apiModel.transactionGroupID = String(describing: groupID)
        apiModel.transactions = transactions
        apiModel.signedTransactions = signedTransactions
        return apiModel
    }
}

extension SwapTransactionGroup {
    struct APIModel: ALGAPIModel {
        var purpose: SwapTransactionPurpose?
        var transactionGroupID: String
        var transactions: [Data]?
        var signedTransactions: [Data?]?

        init() {
            self.transactionGroupID = "-1"
        }

        private enum CodingKeys:
            String,
            CodingKey {
            case purpose
            case transactionGroupID = "transaction_group_id"
            case transactions
            case signedTransactions = "signed_transactions"
        }
    }
}
