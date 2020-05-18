//
//  Transaction.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

protocol TransactionItem {}

class Transaction: Model, TransactionItem {
    let round: Int64?
    let id: TransactionID
    let fee: Int64
    let firstRound: Int64
    let noteb64: Data?
    let from: String
    let payment: Payment?
    let lastRound: Int64
    let type: String
    let fromRewards: UInt64?
    let poolError: String?
    let transactionEffect: TransactionEffect?
    let assetFreeze: AssetFreezeTransactionType?
    let assetConfig: AssetConfigTransactionType?
    let assetTransfer: AssetTransferTransactionType?
    
    var status: Status?
    var contact: Contact?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        round = try container.decodeIfPresent(Int64.self, forKey: .round)
        
        let transactionId = try container.decode(String.self, forKey: .id)
        id = TransactionID(identifier: transactionId)
        
        fee = try container.decode(Int64.self, forKey: .fee)
        firstRound = try container.decode(Int64.self, forKey: .firstRound)
        noteb64 = try container.decodeIfPresent(Data.self, forKey: .noteb64)
        from = try container.decode(String.self, forKey: .from)
        payment = try container.decodeIfPresent(Payment.self, forKey: .payment)
        lastRound = try container.decode(Int64.self, forKey: .lastRound)
        type = try container.decode(String.self, forKey: .type)
        fromRewards = try container.decodeIfPresent(UInt64.self, forKey: .fromRewards)
        poolError = try container.decodeIfPresent(String.self, forKey: .poolError)
        transactionEffect = try container.decodeIfPresent(TransactionEffect.self, forKey: .transactionEffect)
        assetFreeze = try container.decodeIfPresent(AssetFreezeTransactionType.self, forKey: .assetFreeze)
        assetConfig = try container.decodeIfPresent(AssetConfigTransactionType.self, forKey: .assetConfig)
        assetTransfer = try container.decodeIfPresent(AssetTransferTransactionType.self, forKey: .assetTransfer)
    }
}

extension Transaction {
    func isPending() -> Bool {
        if let status = status {
            return status == .pending
        }
        return round == nil || round == 0
    }
}

extension Transaction {
    enum CodingKeys: String, CodingKey {
        case round = "round"
        case id = "tx"
        case fee = "fee"
        case firstRound = "first-round"
        case noteb64 = "noteb64"
        case from = "from"
        case payment = "payment"
        case lastRound = "last-round"
        case type = "type"
        case fromRewards = "fromrewards"
        case poolError = "poolerror"
        case transactionEffect = "txresults"
        case assetFreeze = "curfrz"
        case assetConfig = "curcfg"
        case assetTransfer = "curxfer"
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
    enum Constant {
        static let minimumFee: Int64 = 1000
    }
}

extension Transaction {
    func isAssetCreationTransaction(for account: String) -> Bool {
        guard let assetTransfer = assetTransfer else {
            return false
        }
        return assetTransfer.receiverAddress == account && assetTransfer.amount == 0
    }
}
