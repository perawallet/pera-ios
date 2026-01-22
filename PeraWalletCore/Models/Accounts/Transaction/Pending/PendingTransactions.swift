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
//  PendingTransactions.swift

import Foundation
import MagpieCore
import MacaroonUtils

public final class PendingTransaction:
    ALGEntityModel,
    TransactionItem,
    Hashable {
    
    public let id: String? = .empty
    public let signature: String?
    private let algosAmount: UInt64?
    private let assetAmount: UInt64?
    public let fee: UInt64?
    public let fv: UInt64?
    public let gh: String?
    public let lv: UInt64?
    private let assetReceiver: String?
    private let algosReceiver: String?
    public let sender: String?
    public let type: TransactionType?
    public let assetID: Int64?
    public let confirmedRound: Int64?
    public let poolError: String?
    public let appId: Int64? = 0
    public var status: TransactionStatus? = .pending
    public var noteRepresentation: String?

    public var amount: UInt64 {
        return assetAmount ?? algosAmount ?? 0
    }
    
    public var receiver: String? {
        return assetReceiver ?? algosReceiver
    }
    
    
    public var allInnerTransactionsCount: Int { 0 }
    
    public func isPending() -> Bool { true }
    
    public var isSelfTransaction: Bool {
        guard let sender, let receiver else { return false}
        return sender == receiver
    }
    
    public var contact: Contact?

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.signature = apiModel.signature
        self.algosAmount = apiModel.txn?.amt
        self.assetAmount = apiModel.txn?.aamt
        self.fee = apiModel.txn?.fee
        self.fv = apiModel.txn?.fv
        self.gh = apiModel.txn?.gh
        self.lv = apiModel.txn?.lv
        self.assetReceiver = apiModel.txn?.arcv
        self.algosReceiver = apiModel.txn?.rcv
        self.sender = apiModel.txn?.snd
        self.type = apiModel.txn?.type
        self.assetID = apiModel.txn?.xaid
        self.confirmedRound = apiModel.confirmedRound
        self.poolError = apiModel.poolError
    }

    public func encode() -> APIModel {
        var transaction = APIModel.TransactionDetail()
        transaction.amt = algosAmount
        transaction.aamt = assetAmount
        transaction.fee = fee
        transaction.fv = fv
        transaction.gh = gh
        transaction.lv = lv
        transaction.arcv = assetReceiver
        transaction.rcv = algosReceiver
        transaction.snd = sender
        transaction.type = type
        transaction.xaid = assetID

        var apiModel = APIModel()
        apiModel.sig = signature
        apiModel.txn = transaction
        apiModel.confirmedRound = confirmedRound
        apiModel.poolError = poolError
        return apiModel
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(signature)
        hasher.combine(sender)
        hasher.combine(receiver)
        hasher.combine(amount)
        hasher.combine(type)
        hasher.combine(lv)
        hasher.combine(fv)
        hasher.combine(assetID)
        hasher.combine(poolError)
        hasher.combine(confirmedRound)
    }
    
    public static func == (lhs: PendingTransaction, rhs: PendingTransaction) -> Bool {
        return lhs.signature == rhs.signature &&
        lhs.sender == rhs.sender &&
        lhs.receiver == rhs.receiver &&
        lhs.amount == rhs.amount &&
        lhs.type == rhs.type &&
        lhs.lv == rhs.lv &&
        rhs.fv == rhs.fv &&
        rhs.assetID == rhs.assetID
    }
}

extension PendingTransaction {
    ///TODO: Code duplication should be handled
    public func isAssetAdditionTransaction(for address: String) -> Bool {
        return assetReceiver == address &&
        assetAmount == 0 &&
        type == .assetTransfer &&
        sender == address
    }

    /// <note>
    /// Transaction committed -> committed round > 0
    /// Still in the pool -> committed round = 0 & pool error = ""
    /// Removed from the pool due to error -> committed round = 0 & pool error != ""
    /// https://developer.algorand.org/docs/rest-apis/algod/v2/#pendingtransactionresponse
    public func getTransactionStatus() -> Status {
        if let confirmedRound,
           confirmedRound > 0 {
            return .completed
        }

        if let poolError,
           let confirmedRound,
           confirmedRound == 0 {
            if !poolError.isEmpty {
                return .failed
            }

            return .inProgress
        }

        return .inProgress
    }
}

extension PendingTransaction {
    public enum Status {
        case inProgress
        case completed
        case failed
    }
}

extension PendingTransaction {
    public struct APIModel: ALGAPIModel {
        var sig: String?
        var txn: TransactionDetail?
        var lsig: LogicSignature?
        var msig: MultiSignature?
        var confirmedRound: Int64?
        var poolError: String?
        
        var signature: String? {
            sig ?? lsig?.l ?? msig?.signature
        }

        public init() {
            self.sig = nil
            self.txn = nil
            self.lsig = nil
            self.msig = nil
            self.confirmedRound = nil
            self.poolError = nil
        }
    }
}

extension PendingTransaction.APIModel {
    private enum CodingKeys:
        String,
        CodingKey {
        case sig
        case txn
        case lsig
        case msig
        case confirmedRound = "confirmed-round"
        case poolError = "pool-error"
    }
}

extension PendingTransaction.APIModel {
    struct LogicSignature: ALGAPIModel {
        var l: String
        
        init() {
            self.l = ""
        }
    }
}

extension PendingTransaction.APIModel.LogicSignature {
    private enum CodingKeys:
        String,
        CodingKey {
        case l = "l"
    }
}

extension PendingTransaction.APIModel {
    struct MultiSignature: ALGAPIModel {
        var subsig: [MultiSubSignature]
        
        var signature: String? {
            var combinedSignature: String?
            
            for signature in subsig {
                guard let signatureValue = signature.s else {
                    continue
                }
                
                if let oldCombinedSignature = combinedSignature {
                    combinedSignature = oldCombinedSignature.appending(signatureValue)
                } else {
                    combinedSignature = signatureValue
                }
            }
            
            return combinedSignature
        }
        
        init() {
            self.subsig = []
        }
    }
}

extension PendingTransaction.APIModel.MultiSignature {
    private enum CodingKeys:
        String,
        CodingKey {
        case subsig = "subsig"
    }
}

extension PendingTransaction.APIModel.MultiSignature {
    struct MultiSubSignature: ALGAPIModel {
        var pk: String?
        var s: String?
        
        init() {
            self.pk = nil
            self.s = nil
        }
    }
}

extension PendingTransaction.APIModel.MultiSignature.MultiSubSignature {
    private enum CodingKeys:
        String,
        CodingKey {
        case pk = "pk"
        case s = "s"
    }
}

extension PendingTransaction.APIModel {
    struct TransactionDetail: ALGAPIModel {
        var amt: UInt64?
        var aamt: UInt64?
        var fee: UInt64?
        var fv: UInt64?
        var gh: String?
        var lv: UInt64?
        var rcv: String?
        var arcv: String?
        var snd: String?
        var xaid: Int64?
        var type: TransactionType?

        init() {
            self.amt = nil
            self.aamt = nil
            self.fee = nil
            self.fv = nil
            self.gh = nil
            self.lv = nil
            self.rcv = nil
            self.arcv = nil
            self.snd = nil
            self.xaid = nil
            self.type = nil
        }
    }
}
