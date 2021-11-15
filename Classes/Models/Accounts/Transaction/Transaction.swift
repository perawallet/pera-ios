// Copyright 2019 Algorand, Inc.

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

protocol TransactionItem {}

final class Transaction: ALGResponseModel, TransactionItem {
    var debugData: Data?

    let closeRewards: UInt64?
    let closeAmount: UInt64?
    let confirmedRound: UInt64?
    let fee: UInt64?
    let firstRound: UInt64?
    let id: String?
    let lastRound: UInt64?
    let note: Data?
    let payment: Payment?
    let receiverRewards: UInt64?
    let sender: String?
    let senderRewards: UInt64?
    let type: TransferType?
    let createdAssetId: Int64?
    let assetFreeze: AssetFreezeTransaction?
    let assetConfig: AssetConfigTransaction?
    let assetTransfer: AssetTransferTransaction?
    let date: Date?
    let transactionSignature: TransactionSignature?
    
    var status: Status?
    var contact: Contact?

    init(_ apiModel: APIModel = APIModel()) {
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
        self.type = apiModel.txType
        self.createdAssetId = apiModel.createdAssetIndex
        self.assetFreeze = apiModel.assetFreezeTransaction.unwrap(AssetFreezeTransaction.init)
        self.assetConfig = apiModel.assetConfigTransaction.unwrap(AssetConfigTransaction.init)
        self.assetTransfer = apiModel.assetTransferTransaction.unwrap(AssetTransferTransaction.init)

        if let dateValue = apiModel.roundTime {
            self.date = Date(timeIntervalSince1970: dateValue)
        }

        self.transactionSignature = apiModel.signature.unwrap(TransactionSignature.init)
    }
}

extension Transaction {
    struct APIModel: ALGAPIModel {
        let closeRewards: UInt64?
        let closeAmount: UInt64?
        let confirmedRound: UInt64?
        let fee: UInt64?
        let firstValid: UInt64?
        let id: String?
        let lastValid: UInt64?
        let note: Data?
        let paymentTransaction: Payment.APIModel?
        let receiverRewards: UInt64?
        let sender: String?
        let senderRewards: UInt64?
        let txType: TransferType?
        let createdAssetIndex: Int64?
        let assetFreezeTransaction: AssetFreezeTransaction.APIModel?
        let assetConfigTransaction: AssetConfigTransaction.APIModel?
        let assetTransferTransaction: AssetTransferTransaction.APIModel?
        let roundTime: Double?
        let signature: TransactionSignature.APIModel?

        init() {
            closeRewards = nil
            closeAmount = nil
            confirmedRound = nil
            fee = nil
            firstValid = nil
            id = nil
            lastValid = nil
            note = nil
            paymentTransaction = nil
            receiverRewards = nil
            sender = nil
            senderRewards = nil
            txType = nil
            createdAssetIndex = nil
            assetFreezeTransaction = nil
            assetConfigTransaction = nil
            assetTransferTransaction = nil
            roundTime = nil
            signature = nil
        }
    }
}

extension Transaction {
    func isPending() -> Bool {
        if let status = status {
            return status == .pending
        }
        return confirmedRound == nil || confirmedRound == 0
    }

    func isSelfTransaction() -> Bool {
        return sender == getReceiver()
    }
    
    func isAssetAdditionTransaction(for address: String) -> Bool {
        guard let assetTransfer = assetTransfer else {
            return false
        }
        
        return assetTransfer.receiverAddress == address && assetTransfer.amount == 0 && type == .assetTransfer
    }
    
    func getAmount() -> UInt64? {
        return payment?.amount ?? assetTransfer?.amount
    }

    func getRewards(for account: String) -> UInt64? {
        return account == sender ? senderRewards : (account == getReceiver() ? receiverRewards : nil)
    }
    
    func getReceiver() -> String? {
        return payment?.receiver ?? assetTransfer?.receiverAddress
    }
    
    func getCloseAmount() -> UInt64? {
        return payment?.closeAmount ?? assetTransfer?.closeAmount
    }
    
    func getCloseAddress() -> String? {
        return payment?.closeAddress ?? assetTransfer?.closeToAddress
    }
    
    func noteRepresentation() -> String? {
        guard let noteData = note, !noteData.isEmpty else {
            return nil
        }
        
        return String(data: noteData, encoding: .utf8) ?? noteData.base64EncodedString()
    }

    func isAssetCreationTransaction(for account: String) -> Bool {
        guard let assetTransfer = assetTransfer else {
            return false
        }
        return assetTransfer.receiverAddress == account && assetTransfer.amount == 0
    }
}

extension Transaction {
    enum Status: String {
        case pending = "PENDING"
        case completed = "COMPLETED"
        case failed = "FAILED"
    }
}

extension Transaction {
    enum TransferType: String, ALGAPIModel {
        case payment = "pay"
        case keyreg = "keyreg"
        case assetConfig = "acfg"
        case assetTransfer = "axfer"
        case assetFreeze = "afrz"
        case applicationCall = "appl"

        init() { }
    }
}

extension Transaction {
    enum Constant {
        static let minimumFee: UInt64 = 1000
    }
}
