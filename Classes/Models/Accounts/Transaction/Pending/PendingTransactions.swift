//
//  PendingTransactions.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class PendingTransaction: Model, TransactionItem {
    let signature: String?
    let amount: Int64?
    let assetAmount: Int64?
    let fee: Int64?
    let fv: Int64?
    let gh: String?
    let lv: Int64?
    let assetReceiver: String?
    let receiver: String?
    let sender: String?
    let type: Transaction.TransferType?
    
    var contact: Contact?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        signature = try container.decodeIfPresent(String.self, forKey: .signature)
        let transactionContainer = try container.nestedContainer(keyedBy: TransactionCodingKeys.self, forKey: .transaction)
        
        amount = try transactionContainer.decodeIfPresent(Int64.self, forKey: .amount)
        assetAmount = try transactionContainer.decodeIfPresent(Int64.self, forKey: .assetAmount)
        fee = try transactionContainer.decodeIfPresent(Int64.self, forKey: .fee)
        fv = try transactionContainer.decodeIfPresent(Int64.self, forKey: .fv)
        gh = try transactionContainer.decodeIfPresent(String.self, forKey: .gh)
        lv = try transactionContainer.decodeIfPresent(Int64.self, forKey: .lv)
        receiver = try transactionContainer.decodeIfPresent(String.self, forKey: .receiver)
        assetReceiver = try transactionContainer.decodeIfPresent(String.self, forKey: .assetReceiver)
        sender = try transactionContainer.decodeIfPresent(String.self, forKey: .sender)
        type = try transactionContainer.decodeIfPresent(Transaction.TransferType.self, forKey: .type)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(signature, forKey: .signature)
        
        var transactionContainer = container.nestedContainer(keyedBy: TransactionCodingKeys.self, forKey: .transaction)
        try transactionContainer.encodeIfPresent(amount, forKey: .amount)
        try transactionContainer.encodeIfPresent(assetAmount, forKey: .assetAmount)
        try transactionContainer.encodeIfPresent(fee, forKey: .fee)
        try transactionContainer.encodeIfPresent(fv, forKey: .fv)
        try transactionContainer.encodeIfPresent(gh, forKey: .gh)
        try transactionContainer.encodeIfPresent(lv, forKey: .lv)
        try transactionContainer.encodeIfPresent(receiver, forKey: .receiver)
        try transactionContainer.encodeIfPresent(assetReceiver, forKey: .assetReceiver)
        try transactionContainer.encodeIfPresent(sender, forKey: .sender)
        try transactionContainer.encodeIfPresent(type, forKey: .type)
    }
}

extension PendingTransaction {
    private enum CodingKeys: String, CodingKey {
        case signature = "sig"
        case transaction = "txn"
    }
    
    private enum TransactionCodingKeys: String, CodingKey {
        case amount = "amt"
        case assetAmount = "aamt"
        case fee = "fee"
        case fv = "fv"
        case gh = "gh"
        case lv = "lv"
        case receiver = "rcv"
        case assetReceiver = "arcv"
        case sender = "snd"
        case type = "type"
    }
}

extension PendingTransaction {
    func getReceiver() -> String? {
        return assetReceiver ?? receiver
    }
    
    func getAmount() -> Int64? {
        return assetAmount ?? amount
    }
}
