//
//  AccountInformation.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 3.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

class AccountInformation: Model {
    let address: String
    var name: String
    var type: AccountType = .standard
    var ledgerDetail: LedgerDetail?
    
    init(address: String, name: String, type: AccountType = .standard, ledgerDetail: LedgerDetail? = nil) {
        self.address = address
        self.name = name
        self.type = type
        self.ledgerDetail = ledgerDetail
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decode(String.self, forKey: .address)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decodeIfPresent(AccountType.self, forKey: .type) ?? .standard
        ledgerDetail = try container.decodeIfPresent(LedgerDetail.self, forKey: .ledgerDetail)
    }
}

extension AccountInformation {
    func updateName(_ name: String) {
        self.name = name
    }
    
    func mnemonics() -> [String]? {
        if type == .watcher || type == .ledger {
            return nil
        }
        return UIApplication.shared.appConfiguration?.session.mnemonics(forAccount: address)
    }
    
    func hasWriteAccess() -> Bool {
        return type != .watcher
    }
    
    func encoded() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

extension AccountInformation {
    enum CodingKeys: String, CodingKey {
        case address = "address"
        case name = "name"
        case type = "type"
        case ledgerDetail = "ledgerDetail"
    }
}

extension AccountInformation: Encodable { }

extension AccountInformation: Equatable {
    static func == (lhs: AccountInformation, rhs: AccountInformation) -> Bool {
        return lhs.address == rhs.address
    }
}

enum AccountType: String, Model {
    case standard = "standard"
    case watcher = "watcher"
    case ledger = "ledger"
    case multiSig = "multiSig"
    case rekeyed = "rekeyed"
    
    func isLedger() -> Bool {
        return self == .ledger
    }
    
    func isRekeyed() -> Bool {
        return self == .rekeyed
    }
}

extension AccountType: Encodable { }
