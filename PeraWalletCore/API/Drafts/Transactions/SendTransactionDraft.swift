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
//   SendTransactionDraft.swift


import Foundation

public struct SendTransactionDraft: TransactionSendDraft {
    public var from: Account
    public var toAccount: Account?
    public var amount: Decimal?
    public var fee: UInt64?
    public var isMaxTransaction: Bool {
        get {
            switch transactionMode {
            case .algo:
                return self.amount == from.algo.amount.toAlgos
            case .asset(let asset):
                return self.amount == asset.amountWithFraction
            }
        }

        set {
        }
    }
    public var identifier: String?
    public var transactionMode: TransactionMode

    public var fractionCount: Int {
        switch transactionMode {
        case .algo:
            return algosFraction
        case .asset(let asset):
            return asset.decimals
        }
    }
    public var toContact: Contact?
    public var note: String?
    public var lockedNote: String?

    public var asset: Asset? {
        switch transactionMode {
        case .algo:
            return nil
        case .asset(let asset):
            return asset
        }
    }

    public var hasReceiver: Bool {
        toAccount != nil || toContact != nil
    }
    public var toNameService: NameService?
    public var isOptingOut = false
    public var isReceiverOptingInToAsset = false
    
    public init(from: Account, toAccount: Account? = nil, amount: Decimal? = nil, fee: UInt64? = nil, identifier: String? = nil, transactionMode: TransactionMode, toContact: Contact? = nil, note: String? = nil, lockedNote: String? = nil, toNameService: NameService? = nil, isOptingOut: Bool = false, isReceiverOptingInToAsset: Bool = false) {
        self.from = from
        self.toAccount = toAccount
        self.amount = amount
        self.fee = fee
        self.identifier = identifier
        self.transactionMode = transactionMode
        self.toContact = toContact
        self.note = note
        self.lockedNote = lockedNote
        self.toNameService = toNameService
        self.isOptingOut = isOptingOut
        self.isReceiverOptingInToAsset = isReceiverOptingInToAsset
    }
 }

public enum TransactionMode {
    case algo
    case asset(Asset)
}
