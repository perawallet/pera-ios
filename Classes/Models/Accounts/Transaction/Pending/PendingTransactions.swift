// Copyright 2022 Pera Wallet, LDA

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

final class PendingTransaction:
    ALGEntityModel,
    TransactionItem,
    Hashable {
    
    let signature: String?
    private let algosAmount: UInt64?
    private let assetAmount: UInt64?
    let fee: UInt64?
    let fv: UInt64?
    let gh: String?
    let lv: UInt64?
    private let assetReceiver: String?
    private let algosReceiver: String?
    let sender: String?
    let type: Transaction.TransferType?
    
    var amount: UInt64 {
        return assetAmount ?? algosAmount ?? 0
    }
    
    var receiver: String? {
        return assetReceiver ?? algosReceiver
    }
    
    var contact: Contact?

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.signature = apiModel.sig
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
    }

    func encode() -> APIModel {
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

        var apiModel = APIModel()
        apiModel.sig = signature
        apiModel.txn = transaction
        return apiModel
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(signature)
        hasher.combine(sender)
        hasher.combine(receiver)
        hasher.combine(amount)
        hasher.combine(type)
    }
    
    static func == (lhs: PendingTransaction, rhs: PendingTransaction) -> Bool {
        return lhs.signature == rhs.signature &&
        lhs.sender == rhs.sender &&
        lhs.receiver == rhs.receiver &&
        lhs.amount == rhs.amount &&
        lhs.type == rhs.type
    }
}

extension PendingTransaction {
    ///TODO: Code duplication should be handled
    func isAssetAdditionTransaction(for address: String) -> Bool {
        return assetReceiver == address &&
        assetAmount == 0 &&
        type == .assetTransfer &&
        sender == address
    }
}

extension PendingTransaction {
    struct APIModel: ALGAPIModel {
        var sig: String?
        var txn: TransactionDetail?

        init() {
            self.sig = nil
            self.txn = nil
        }
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
        var type: Transaction.TransferType?

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
            self.type = nil
        }
    }
}
