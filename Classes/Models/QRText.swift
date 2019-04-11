//
//  QRText.swift
//  algorand
//
//  Created by Omer Emre Aslan on 28.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

struct QRText: Codable {
    let mode: QRMode
    let text: String
    let version = "1.0"
    
    let amount: Int64?
    
    init(mode: QRMode, text: String, amount: Int64? = 0) {
        self.mode = mode
        self.text = text
        self.amount = amount
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if let address = try values.decodeIfPresent(String.self, forKey: .address) {
            mode = .address
            text = address
        } else if let mnemonic = try values.decodeIfPresent(String.self, forKey: .mnemonic) {
            mode = .mnemonic
            text = mnemonic
        } else {
            mode = .address
            text = ""
        }
        
        amount = try values.decodeIfPresent(Int64.self, forKey: .amount)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch mode {
        case .address:
            try container.encode(text, forKey: .address)
        case .mnemonic:
            try container.encode(text, forKey: .mnemonic)
        case .algosReceive:
            try container.encode(text, forKey: .address)
        }
        
        try container.encode(version, forKey: .version)
        
        if let amount = amount {
            try container.encode(amount, forKey: .amount)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case address = "address"
        case mnemonic = "mnemonic"
        case version = "version"
        case amount = "amount"
    }
}
