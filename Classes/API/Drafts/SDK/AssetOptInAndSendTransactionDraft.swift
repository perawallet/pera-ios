// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AssetOptInAndSendTransactionDraft.swift

import Foundation

struct AssetOptInAndSendTransactionDraft: TransactionDraft {
    var from: Account
    let toAccount: String
    var transactionParams: TransactionParams
    let amount: UInt64
    let senderAlgoBalance: UInt64
    let senderMinBalance: UInt64
    let receiverAlgoBalance: UInt64
    let receiverMinBalance: UInt64
    let assetIndex: Int64
    var note: Data?
}
