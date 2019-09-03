//
//  TransactionFee.swift
//  algorand
//
//  Created by Omer Emre Aslan on 4.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct TransactionParams: Model {
    let fee: Int64
    let lastRound: Int64
    let genesisHashData: Data?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        fee = try container.decode(Int64.self, forKey: .fee)
        lastRound = try container.decode(Int64.self, forKey: .lastRound)
        if let genesisHashBase64String = try container.decodeIfPresent(String.self, forKey: .genesisHash) {
            genesisHashData = Data(base64Encoded: genesisHashBase64String)
        } else {
            genesisHashData = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fee, forKey: .fee)
        try container.encode(lastRound, forKey: .lastRound)
        try container.encodeIfPresent(genesisHashData, forKey: .genesisHash)
    }
}

extension TransactionParams {
    private enum CodingKeys: String, CodingKey {
        case lastRound = "lastRound"
        case fee = "fee"
        case genesisHash = "genesishashb64"
    }
}
