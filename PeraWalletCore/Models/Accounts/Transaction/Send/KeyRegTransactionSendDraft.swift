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

//   KeyRegTransactionSendDraft.swift

import Foundation

public struct KeyRegTransactionSendDraft: TransactionSendDraft {
    public var from: Account
    public var toAccount: Account? = nil
    public var amount: Decimal? = nil
    public var fee: UInt64?
    public var isMaxTransaction = false
    public var identifier: String?
    public var note: String?
    public var lockedNote: String?
    public var toContact: Contact? = nil
    public var toNameService: NameService? = nil
    public let stateProofKey: String?
    public let voteKey: String?
    public let selectionKey: String?
    public let voteFirst: UInt64?
    public let voteLast: UInt64?
    public let voteKeyDilution: UInt64?
    
    public init(
        from: Account,
        toAccount: Account? = nil,
        amount: Decimal? = nil,
        fee: UInt64? = nil,
        isMaxTransaction: Bool = false,
        identifier: String? = nil,
        note: String? = nil,
        lockedNote: String? = nil,
        toContact: Contact? = nil,
        toNameService: NameService? = nil,
        stateProofKey: String?,
        voteKey: String?,
        selectionKey: String?,
        voteFirst: UInt64?,
        voteLast: UInt64?,
        voteKeyDilution: UInt64?
    ) {
        self.from = from
        self.toAccount = toAccount
        self.amount = amount
        self.fee = fee
        self.isMaxTransaction = isMaxTransaction
        self.identifier = identifier
        self.note = note
        self.lockedNote = lockedNote
        self.toContact = toContact
        self.toNameService = toNameService
        self.stateProofKey = stateProofKey
        self.voteKey = voteKey
        self.selectionKey = selectionKey
        self.voteFirst = voteFirst
        self.voteLast = voteLast
        self.voteKeyDilution = voteKeyDilution
    }
    
    public init(
        account: Account,
        qrText: QRText
    ) {
        from = account
        fee = qrText.keyRegTransactionQRData?.fee
        note = qrText.note
        lockedNote = qrText.lockedNote
        stateProofKey = qrText.keyRegTransactionQRData?.stateProofKey
        voteKey = qrText.keyRegTransactionQRData?.votingKey
        selectionKey = qrText.keyRegTransactionQRData?.selectionKey
        voteFirst = qrText.keyRegTransactionQRData?.voteFirst
        voteLast = qrText.keyRegTransactionQRData?.voteLast
        voteKeyDilution = qrText.keyRegTransactionQRData?.voteKeyDilution
    }
    
    #if DEBUG
        public static var mock: KeyRegTransactionSendDraft {
            .init(
                from: Account(address: "YVRRLLVBX54N44WG4EZJWPXXA6RROAU5TLHB4XHCMZFVZBVCB6KSDWDSEQ"),
                lockedNote: "Locked note",
                stateProofKey: "-V3Kb9a2Ujba0DpARpJkX-7MJp2gdpoMqg0b_TdyjrJIsNrK0NUSVf7XOhFIVIRnBfS0KZWSHXtBryoYtBJCAw",
                voteKey: "GtwJkXPXquQJycTrIeT1KT4kKoOOe_vX49CjoHGzRnQ",
                selectionKey: "6IxPNEBygNOoOnjCAf6c3cMfoUbtbVM9PKzg-aE6I24",
                voteFirst: 2502377,
                voteLast: 2509977,
                voteKeyDilution: 100
            )
        }
    #endif
}
