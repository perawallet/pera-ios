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
//  AssetTransactionDraft.swift

import Foundation

public struct AssetTransactionDraft: TransactionDraft {
    public var from: Account
    public let toAccount: String
    public var transactionParams: TransactionParams
    public let amount: UInt64
    public let assetIndex: Int64
    public var note: Data?
    public var closeTo: String?
    
    public init(from: Account, toAccount: String, transactionParams: TransactionParams, amount: UInt64, assetIndex: Int64, note: Data? = nil, closeTo: String? = nil) {
        self.from = from
        self.toAccount = toAccount
        self.transactionParams = transactionParams
        self.amount = amount
        self.assetIndex = assetIndex
        self.note = note
        self.closeTo = closeTo
    }
}
