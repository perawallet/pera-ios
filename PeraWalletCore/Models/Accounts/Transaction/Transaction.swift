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
//  Transaction.swift

import Foundation
import MagpieCore
import MacaroonUtils

public protocol TransactionItem {
    var date: Date? { get }
}

extension TransactionItem {
    public var date: Date? {
        return nil
    }
}

public final class Transaction:
    ALGEntityModel,
    TransactionItem {
    public let closeRewards: UInt64?
    public let closeAmount: UInt64?
    public let confirmedRound: UInt64?
    public let fee: UInt64?
    public let firstRound: UInt64?
    public let id: String?
    public let lastRound: UInt64?
    public let note: Data?
    public let payment: Payment?
    public let receiverRewards: UInt64?
    public let sender: String?
    public let senderRewards: UInt64?
    public let type: TransactionType
    public let assetFreeze: AssetFreezeTransaction?
    public let assetConfig: AssetConfigTransaction?
    public let assetTransfer: AssetTransferTransaction?
    public let applicationCall: AppCallTransaction?
    public let keyRegTransaction: KeyRegTransaction?
    public let date: Date?
    public let transactionSignature: TransactionSignature?
    public let groupKey: String?
    public let innerTransactions: [Transaction]?

    /// <note>:
    /// If transaction is inner transaction, its parentID is set to parent transaction ID.
    public var parentID: String?

    public var status: Status?
    public var contact: Contact?

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.closeRewards = apiModel.closeRewards
        self.closeAmount = apiModel.closeAmount
        self.confirmedRound = apiModel.confirmedRound
        self.fee = apiModel.fee
        self.firstRound = apiModel.firstValid
        self.id = apiModel.id
        self.lastRound = apiModel.lastValid
        self.note = apiModel.note
        self.payment = apiModel.paymentTransaction.unwrap(Payment.init)
        self.receiverRewards = apiModel.receiverRewards
        self.sender = apiModel.sender
        self.senderRewards = apiModel.senderRewards
        self.type = apiModel.txType.unwrap(TransactionType.init(rawValue:)) ?? .random()
        self.assetFreeze = apiModel.assetFreezeTransaction
        self.assetConfig = apiModel.assetConfigTransaction
        self.applicationCall = apiModel.applicationCall
        self.keyRegTransaction = apiModel.keyRegTransaction
        self.assetTransfer = apiModel.assetTransferTransaction.unwrap(AssetTransferTransaction.init)
        self.date = apiModel.roundTime.unwrap { Date(timeIntervalSince1970: $0) }
        self.transactionSignature = apiModel.signature
        self.groupKey = apiModel.group
        self.innerTransactions = apiModel.innerTransactions.unwrapMap(Transaction.init)
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.closeRewards = closeRewards
        apiModel.closeAmount = closeAmount
        apiModel.fee = fee
        apiModel.firstValid = firstRound
        apiModel.id = id
        apiModel.lastValid = lastRound
        apiModel.note = note
        apiModel.paymentTransaction = payment?.encode()
        apiModel.receiverRewards = receiverRewards
        apiModel.sender = sender
        apiModel.senderRewards = senderRewards
        apiModel.txType = type.rawValue
        apiModel.assetFreezeTransaction = assetFreeze
        apiModel.assetConfigTransaction = assetConfig
        apiModel.applicationCall = applicationCall
        apiModel.keyRegTransaction = keyRegTransaction
        apiModel.assetTransferTransaction = assetTransfer?.encode()
        apiModel.roundTime = date?.timeIntervalSince1970
        apiModel.signature = transactionSignature
        apiModel.innerTransactions = innerTransactions.map { $0.encode() }
        apiModel.group = groupKey
        return apiModel
    }
}

extension Transaction {
    public func isPending() -> Bool {
        if let status = status {
            return status == .pending
        }
        return confirmedRound == nil || confirmedRound == 0
    }

    public var isSelfTransaction: Bool {
        return sender == getReceiver()
    }
    
    ///TODO: Code duplication should be handled
    public func isAssetAdditionTransaction(for address: String) -> Bool {
        guard let assetTransfer = assetTransfer else {
            return false
        }
        
        return assetTransfer.receiverAddress == address &&
        sender == address &&
        assetTransfer.amount == 0 &&
        type == .assetTransfer
    }
    
    public func getAmount() -> UInt64? {
        return payment?.amount ?? assetTransfer?.amount
    }

    public func getRewards(for account: String) -> UInt64? {
        return account == sender ? senderRewards : (account == getReceiver() ? receiverRewards : nil)
    }
    
    public func getReceiver() -> String? {
        return payment?.receiver ?? assetTransfer?.receiverAddress
    }
    
    public func getCloseAmount() -> UInt64? {
        return payment?.closeAmount ?? assetTransfer?.closeAmount
    }
    
    public func getCloseAddress() -> String? {
        return payment?.closeAddress ?? assetTransfer?.closeToAddress
    }
    
    public func noteRepresentation() -> String? {
        guard let noteData = note, !noteData.isEmpty else {
            return nil
        }
        
        let note = String(data: noteData, encoding: .utf8) ?? noteData.base64EncodedString()
        let validNote = note.without("\0")
        return validNote
    }

    public func isAssetCreationTransaction(for account: String) -> Bool {
        guard let assetTransfer = assetTransfer else {
            return false
        }
        return assetTransfer.receiverAddress == account &&
        assetTransfer.amount == 0 &&
        sender == account
    }

    public var allInnerTransactionsCount: Int {
        guard let innerTransactions = innerTransactions,
              !innerTransactions.isEmpty else {
            return .zero
        }

        return innerTransactions.reduce(
            innerTransactions.count
        ) { partialResult, transaction in
            partialResult + transaction.allInnerTransactionsCount
        }
    }

    public var isInner: Bool {
        return parentID != nil
    }

    public func setAllParentID(
        _ parentID: String?
    ) {
        guard let innerTransactions = innerTransactions,
              !innerTransactions.isEmpty else {
            return
        }

        innerTransactions.forEach {
            $0.parentID = parentID

            $0.setAllParentID(parentID)
        }
    }

    public func completeAll() {
        guard let innerTransactions = innerTransactions,
              !innerTransactions.isEmpty else {
            status = .completed
            return
        }

        status = .completed

        innerTransactions.forEach { $0.completeAll() }
    }
}

extension Transaction {
    public enum Status: String {
        case pending = "PENDING"
        case completed = "COMPLETED"
        case failed = "FAILED"
        
        public static func == (lhs: Status, rhs: Status) -> Bool {
            lhs.rawValue == rhs.rawValue
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }
}

extension Transaction {
    public enum Constant {
        public static let minimumFee: UInt64 = 1000
    }
}

extension Transaction {
    public struct APIModel: ALGAPIModel {
        var closeRewards: UInt64?
        var closeAmount: UInt64?
        var confirmedRound: UInt64?
        var fee: UInt64?
        var firstValid: UInt64?
        var id: String?
        var lastValid: UInt64?
        var note: Data?
        var paymentTransaction: Payment.APIModel?
        var receiverRewards: UInt64?
        var sender: String?
        var senderRewards: UInt64?
        var txType: String?
        var assetFreezeTransaction: AssetFreezeTransaction?
        var assetConfigTransaction: AssetConfigTransaction?
        var assetTransferTransaction: AssetTransferTransaction.APIModel?
        var applicationCall: AppCallTransaction?
        var keyRegTransaction: KeyRegTransaction?
        var roundTime: Double?
        var signature: TransactionSignature?
        var group: String?
        var innerTransactions: [Transaction.APIModel]?

        public init() {
            self.closeRewards = nil
            self.closeAmount = nil
            self.confirmedRound = nil
            self.fee = nil
            self.firstValid = nil
            self.id = nil
            self.lastValid = nil
            self.note = nil
            self.paymentTransaction = nil
            self.receiverRewards = nil
            self.sender = nil
            self.senderRewards = nil
            self.txType = nil
            self.assetFreezeTransaction = nil
            self.assetConfigTransaction = nil
            self.assetTransferTransaction = nil
            self.applicationCall = nil
            self.keyRegTransaction = nil
            self.roundTime = nil
            self.signature = nil
            self.group = nil
            self.innerTransactions = nil
        }

        private enum CodingKeys: String, CodingKey {
            case closeRewards = "close-rewards"
            case closeAmount = "closing-amount"
            case confirmedRound = "confirmed-round"
            case fee
            case firstValid = "first-valid"
            case id
            case lastValid = "last-valid"
            case note
            case paymentTransaction = "payment-transaction"
            case receiverRewards = "receiver-rewards"
            case sender
            case senderRewards = "sender-rewards"
            case txType = "tx-type"
            case assetFreezeTransaction = "asset-freeze-transaction"
            case assetConfigTransaction = "asset-config-transaction"
            case assetTransferTransaction = "asset-transfer-transaction"
            case applicationCall = "application-transaction"
            case keyRegTransaction = "keyreg-transaction"
            case roundTime = "round-time"
            case signature
            case group
            case innerTransactions = "inner-txns"
        }
    }
}
