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
//  AssetTransactionDisplayDraft.swift

import Foundation

public struct AssetTransactionSendDraft: TransactionSendDraft {
    public var from: Account
    public var toAccount: Account?
    public var amount: Decimal?
    public var fee: UInt64?
    public var isMaxTransaction = false
    public var identifier: String?
    public let assetIndex: Int64?
    public var assetCreator = ""
    public var assetDecimalFraction = 0
    public var isVerifiedAsset = false
    public var note: String?
    public var lockedNote: String?
    public var isReceiverOptingInToAsset = false

    public var toContact: Contact?
    public var asset: Asset?
    public var toNameService: NameService?
    
    public init(from: Account, toAccount: Account? = nil, amount: Decimal? = nil, fee: UInt64? = nil, isMaxTransaction: Bool = false, identifier: String? = nil, assetIndex: Int64?, assetCreator: String = "", assetDecimalFraction: Int = 0, isVerifiedAsset: Bool = false, note: String? = nil, lockedNote: String? = nil, isReceiverOptingInToAsset: Bool = false, toContact: Contact? = nil, asset: Asset? = nil, toNameService: NameService? = nil) {
        self.from = from
        self.toAccount = toAccount
        self.amount = amount
        self.fee = fee
        self.isMaxTransaction = isMaxTransaction
        self.identifier = identifier
        self.assetIndex = assetIndex
        self.assetCreator = assetCreator
        self.assetDecimalFraction = assetDecimalFraction
        self.isVerifiedAsset = isVerifiedAsset
        self.note = note
        self.lockedNote = lockedNote
        self.isReceiverOptingInToAsset = isReceiverOptingInToAsset
        self.toContact = toContact
        self.asset = asset
        self.toNameService = toNameService
    }
}
