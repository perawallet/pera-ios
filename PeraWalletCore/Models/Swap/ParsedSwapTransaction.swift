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

//   ParsedSwapTransaction.swift

import Foundation

public struct ParsedSwapTransaction {
    public let purpose: SwapTransactionPurpose
    public let groupID: String
    public let paidTransactions: [SDKTransaction]
    public let receivedTransactions: [SDKTransaction]
    public let otherTransactions: [SDKTransaction]

    public var allFees: UInt64 {
        return paidTransactions.reduce(0, {$0 + ($1.fee ?? 0) })
    }
    
    public init(
        purpose: SwapTransactionPurpose,
        groupID: String,
        paidTransactions: [SDKTransaction],
        receivedTransactions: [SDKTransaction],
        otherTransactions: [SDKTransaction]
    ) {
        self.purpose = purpose
        self.groupID = groupID
        self.paidTransactions = paidTransactions
        self.receivedTransactions = receivedTransactions
        self.otherTransactions = otherTransactions
    }
}
