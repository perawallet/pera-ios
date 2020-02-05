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
    
    init(address: String, name: String) {
        self.address = address
        self.name = name
    }
}

extension AccountInformation {
    func updateName(_ name: String) {
        self.name = name
    }
    
    func mnemonics() -> [String] {
        return UIApplication.shared.appConfiguration?.session.mnemonics(forAccount: address) ?? []
    }
    
    func encoded() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

extension AccountInformation {
    enum CodingKeys: String, CodingKey {
        case address = "address"
        case name = "name"
    }
}

extension AccountInformation: Encodable { }

extension AccountInformation: Equatable {
    static func == (lhs: AccountInformation, rhs: AccountInformation) -> Bool {
        return lhs.address == rhs.address
    }
}
