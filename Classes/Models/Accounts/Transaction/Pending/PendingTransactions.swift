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
    let amount: Int64
    let fee: Int64
    let fv: Int64?
    let gh: String?
    let lv: Int64?
    let receiver: String
    let sender: String
    let type: Transaction.TransferType
    
    var contact: Contact?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        signature = try container.decodeIfPresent(String.self, forKey: .signature)
        let transactionContainer = try container.nestedContainer(keyedBy: TransactionCodingKeys.self, forKey: .transaction)
        
        amount = try transactionContainer.decode(Int64.self, forKey: .amount)
        fee = try transactionContainer.decode(Int64.self, forKey: .fee)
        fv = try transactionContainer.decodeIfPresent(Int64.self, forKey: .fv)
        gh = try transactionContainer.decodeIfPresent(String.self, forKey: .gh)
        lv = try transactionContainer.decodeIfPresent(Int64.self, forKey: .lv)
        receiver = try transactionContainer.decode(String.self, forKey: .receiver)
        sender = try transactionContainer.decode(String.self, forKey: .sender)
        type = try transactionContainer.decode(Transaction.TransferType.self, forKey: .type)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(signature, forKey: .signature)
        
        var transactionContainer = container.nestedContainer(keyedBy: TransactionCodingKeys.self, forKey: .transaction)
        try transactionContainer.encode(amount, forKey: .amount)
        try transactionContainer.encode(fee, forKey: .fee)
        try transactionContainer.encodeIfPresent(fv, forKey: .fv)
        try transactionContainer.encodeIfPresent(gh, forKey: .gh)
        try transactionContainer.encodeIfPresent(lv, forKey: .lv)
        try transactionContainer.encode(receiver, forKey: .receiver)
        try transactionContainer.encode(sender, forKey: .sender)
        try transactionContainer.encode(type, forKey: .type)
    }
}

extension PendingTransaction {
    private enum CodingKeys: String, CodingKey {
        case signature = "sig"
        case transaction = "txn"
    }
    
    private enum TransactionCodingKeys: String, CodingKey {
        case amount = "amt"
        case fee = "fee"
        case fv = "fv"
        case gh = "gh"
        case lv = "lv"
        case receiver = "rcv"
        case sender = "snd"
        case type = "type"
    }
}
