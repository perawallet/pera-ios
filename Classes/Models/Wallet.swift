//
//  Wallet.swift
//  algorand
//
//  Created by Omer Emre Aslan on 20.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

enum TransactionType: String, Mappable {
    case pay = "pay"
    case keyReg = "keyreg"
}

class Wallet: Mappable {
    let driverName: String?
    let driverVersion: UInt64?
    let identifier: String?
    let mnemonicUx: Bool?
    let name: String?
    let supportedTypes: [TransactionType]?
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        driverName = try values.decodeIfPresent(String.self, forKey: .driverName)
        driverVersion = try values.decodeIfPresent(UInt64.self, forKey: .driverVersion)
        identifier = try values.decodeIfPresent(String.self, forKey: .identifier)
        mnemonicUx = try values.decodeIfPresent(Bool.self, forKey: .mnemonicUx)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        supportedTypes = try values.decodeIfPresent(Array<TransactionType>.self, forKey: .supportedTypes)
    }
}

extension Wallet {
    private enum CodingKeys: String, CodingKey {
        case driverName = "driver_name"
        case driverVersion = "driver_version"
        case identifier = "id"
        case mnemonicUx = "mnemonic_ux"
        case name = "name"
        case supportedTypes = "supported_txs"
    }
}
