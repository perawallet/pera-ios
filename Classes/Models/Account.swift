//
//  Account.swift
//  algorand
//
//  Created by Omer Emre Aslan on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

enum AccountStatus: String, Mappable {
    case offline = "Offline"
    case online = "Online"
    case notParticipating = "NotParticipating"
}

extension AccountStatus: Encodable {
}

class Account: Mappable {
    let address: String
    var amount: UInt64
    var status: AccountStatus
    
    var name: String?
    
    init(address: String) {
        self.address = address
        amount = 0
        status = .offline
    }
    
    func update(withAccount account: Account) {
        amount = account.amount
        status = account.status
        
        if let updatedName = account.name {
            name = updatedName
        }
    }
    
    func mnemonics() -> [String] {
        return UIApplication.shared.appConfiguration?.session.mnemonics(forAccount: self.address) ?? []
    }
    
    func encoded() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

extension Account: Encodable {
}

// MARK: - Equatable
extension Account: Equatable {
    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.address == rhs.address
    }
}
