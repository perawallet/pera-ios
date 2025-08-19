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

//   ARC59SendAssetTransactionDraft.swift

import Foundation

public struct ARC59SendAssetTransactionDraft: TransactionDraft {
    public var from: Account
    public var transactionParams: TransactionParams
    public let receiver: String
    public let appAddress: String
    public let inboxAccount: String?
    public let amount: UInt64
    public let minBalance: UInt64
    public let innerTransactionCount: Int
    public let appID: Int64
    public let assetID: Int64
    public let extraAlgoAmount: UInt64
    public let isOptedInToProtocol: Bool
    
    public init(from: Account, transactionParams: TransactionParams, receiver: String, appAddress: String, inboxAccount: String?, amount: UInt64, minBalance: UInt64, innerTransactionCount: Int, appID: Int64, assetID: Int64, extraAlgoAmount: UInt64, isOptedInToProtocol: Bool) {
        self.from = from
        self.transactionParams = transactionParams
        self.receiver = receiver
        self.appAddress = appAddress
        self.inboxAccount = inboxAccount
        self.amount = amount
        self.minBalance = minBalance
        self.innerTransactionCount = innerTransactionCount
        self.appID = appID
        self.assetID = assetID
        self.extraAlgoAmount = extraAlgoAmount
        self.isOptedInToProtocol = isOptedInToProtocol
    }
}
