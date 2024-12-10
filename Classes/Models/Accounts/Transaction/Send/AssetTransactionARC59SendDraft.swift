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

//   AssetTransactionARC59SendDraft.swift

import Foundation

struct AssetTransactionARC59SendDraft: TransactionSendDraft {
    var from: Account
    var toAccount: Account?
    var toContact: Contact?
    var asset: Asset?
    var toNameService: NameService?
    var amount: Decimal?
    var fee: UInt64?
    var isMaxTransaction = false
    var identifier: String?
    let assetIndex: Int64?
    var assetCreator = ""
    var assetDecimalFraction = 0
    var isVerifiedAsset = false
    var note: String?
    var lockedNote: String?
    let appAddress: String
    let inboxAccount: String?
    let minBalance: UInt64
    let innerTransactionCount: Int
    let appID: Int64
    let extraAlgoAmount: UInt64
    let isOptedInToProtocol: Bool
}
