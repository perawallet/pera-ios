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
    
    func update(withAccount account: Account) {
        amount = account.amount
        status = account.status
    }
    
    func mnemonics() -> [String] {
        return UIApplication.shared.appConfiguration?.session.mnemonics(forAccount: self.address) ?? []
    }
}

extension Account: Encodable {
}
