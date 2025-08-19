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
//  TransactionFetchDraft.swift

import Foundation

public struct TransactionFetchDraft {
    public let account: Account
    public let dates: (from: Date?, to: Date?)
    public let nextToken: String?
    public let assetId: String?
    public let limit: Int?
    public let transactionType: TransactionType?
    
    public init(account: Account, dates: (from: Date?, to: Date?), nextToken: String?, assetId: String?, limit: Int?, transactionType: TransactionType?) {
        self.account = account
        self.dates = dates
        self.nextToken = nextToken
        self.assetId = assetId
        self.limit = limit
        self.transactionType = transactionType
    }
}
