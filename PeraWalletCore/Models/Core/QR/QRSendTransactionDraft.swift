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
//   QRSendTransactionDraft.swift

import Foundation

public struct QRSendTransactionDraft {
    public let toAccount: String
    public let amount: Decimal?
    public let note: String?
    public let lockedNote: String?
    public let transactionMode: TransactionMode
    
    public init(toAccount: String, amount: Decimal?, note: String?, lockedNote: String?, transactionMode: TransactionMode) {
        self.toAccount = toAccount
        self.amount = amount
        self.note = note
        self.lockedNote = lockedNote
        self.transactionMode = transactionMode
    }
}
