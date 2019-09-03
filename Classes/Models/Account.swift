//
//  Account.swift
//  algorand
//
//  Created by Omer Emre Aslan on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

enum AccountStatus: String, Model {
    case offline = "Offline"
    case online = "Online"
    case notParticipating = "NotParticipating"
}

extension AccountStatus: Encodable {
}

class Account: Model {
    let address: String
    var amount: UInt64
    var status: AccountStatus
    var rewards: UInt64?
    var pendingRewards: UInt64?
    
    var name: String?
    
    init(address: String) {
        self.address = address
        amount = 0
        status = .offline
        rewards = 0
        pendingRewards = 0
    }
    
    func update(withAccount account: Account) {
        amount = account.amount
        status = account.status
        rewards = account.rewards
        pendingRewards = account.pendingRewards
        
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

extension Account {
    enum CodingKeys: String, CodingKey {
        case address = "address"
        case amount = "amount"
        case status = "status"
        case rewards = "rewards"
        case pendingRewards = "pendingrewards"
        case name = "name"
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
