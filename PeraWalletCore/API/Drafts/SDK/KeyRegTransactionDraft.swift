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

//   KeyRegTransactionDraft.swift

import Foundation

public struct KeyRegTransactionDraft: TransactionDraft {
    public var from: Account
    public var note: Data?
    public var transactionParams: TransactionParams
    public let voteKey: String?
    public let selectionKey: String?
    public let stateProofKey: String?
    public let voteFirst: Int64?
    public let voteLast: Int64?
    public let voteKeyDilution: Int64?
    public let fee: Int64?
    
    public init(from: Account, note: Data? = nil, transactionParams: TransactionParams, voteKey: String?, selectionKey: String?, stateProofKey: String?, voteFirst: Int64?, voteLast: Int64?, voteKeyDilution: Int64?, fee: Int64?) {
        self.from = from
        self.note = note
        self.transactionParams = transactionParams
        self.voteKey = voteKey
        self.selectionKey = selectionKey
        self.stateProofKey = stateProofKey
        self.voteFirst = voteFirst
        self.voteLast = voteLast
        self.voteKeyDilution = voteKeyDilution
        self.fee = fee
    }
}
